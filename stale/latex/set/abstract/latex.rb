include LatexDocument
include_set Abstract::Pdfjs
include_set Abstract::AceEditor

add_attributes :ignore_tex_errors
attr_accessor :ignore_tex_errors

if Card::Codename.exist? :survey
  LATEX_TYPE_IDS = [Card::SurveyID, Card::LatexID, Card::ProblemID,
                    Card::DefinitionID]
end


def clean_html?
  false
end

event :typeset_latex, :prepare_to_validate, on: :update do
  typeset_document
end

event :store_latex, :finalize, on: :update do
  store_pdf
end

event :create_latex_default_preview, :finalize, :on => :create do
  create_default_preview
end

event :create_latex_subcards, :prepare_to_store, :on => :create do
  create_default_subcards
end

def store_pdf
  unless pdf_exists?
    #new_preview_from_default
    #Env.params[:success][:preview_filename] = doc_basename
  end
  save_preview unless typesetting_preview?
end

def update_preview
  preview_card = Card.fetch "#{self.name}+preview",
                            new: { type: Card::PlainTextID }
  preview_card.content = self.content
  preview_card.save

  preview_pdf_card = Card.fetch "#{self.name}+preview+pdf",
                                new: { type: Card::FileID }
  preview_pdf_card.update_attributes file: File.open(preview_pdf_path, "r")
end

def typeset_document
  content.gsub!("\r\n","\n")
  self.content.gsub!("\r\n","\n")
  return if Env.params[:ignore_errors]
  typeset_preview content
rescue TexTypesetError => e
  errors.add 'LaTeX errors', e.message unless ignore_tex_errors
rescue TexConfigError => e
  errors.add 'LaTeX', e.message
ensure
  if typesetting_preview? && errors.empty?
    Env.params[:success][:preview_filename] = doc_basename
    Card::Auth.as_bot do
      update_preview
    end
    self.content = Card.find(self).content # restore old content
    #abort :success
  end
end

def typesetting_preview?
  (Env.params[:success].is_a?(Hash) ||
    Env.params[:success].is_a?(ActionController::Parameters)) &&
    Env.params[:success][:typeset] == "true"
end

def create_default_subcards
  field 'references'
  field 'discussion'
  field 'preview', content: default_tex_card.content
end

def create_default_preview
  return unless (pdf_card = default_pdf_card)
  Card::Auth.as_bot do
    preview_pdf = Card.fetch "#{name}+preview+pdf",
                             :new => {:type => Card::FileID}
    file = File.open(pdf_card.file.file.file)
    preview_pdf.update_attributes(file: file)

    pdf = Card.fetch "#{name}+pdf", :new => {:type => Card::FileID}
    pdf.update_attributes(file: file )
  end
end

format :json do
  view :preview_path do
    { src: "assets/web/viewer.html?file=#{card.pdf_preview_url}" }.to_json
  end

  view :errors do
    card.format(:html)._render_tex_errors
  end
end

format :html do
  LATEX_EDIT_LAYOUT = "latex_split_layout"
  PDF_VIEW_LAYOUT = "new_layout"

  before :latex_new do
    #args[:hidden] ||= {}
    #args[:hidden][:success] = { :redirect => true, :view=>'split',
    #                            :layout =>LATEX_EDIT_LAYOUT }
    args[:buttons] = %{
    #{ submit_tag 'Submit', :class=>'submit-button btn btn-primary' }
    #{ button_tag 'Cancel',
                  :class=>'cancel-button',
                  :onclick => "window.location.href='#{path(:view=>'open',
                                                            :id=>card.id,
                                                            :layout => PDF_VIEW_LAYOUT)}'",
                  :type=>'button' }
    }
    args
  end

  def new_view_success
    { redirect: true, view: :edit, layout: LATEX_EDIT_LAYOUT }
  end

  before :latex_edit do
    args[:optional_help] = :show
    #args[:hidden] ||= {}
    #args[:hidden][:success] = {:redirect=>true,:view => 'open', :layout=>PDF_VIEW_LAYOUT, :id=>'_self'}
    args[:buttons] = %{
    #{ _render_typeset_fieldset(args) if @slot_view.to_s.eql? 'split' or args[:split]}
    #{ #load_pdf_preview if args[:split]
      }
    #{ submit_tag 'Submit', :class=>'submit-button btn btn-primary yeah' }
    #{ button_tag 'Cancel', :class=>'cancel-button', :onclick => "window.location.href='#{path(:view=>'open',  :id=>card.id, :layout => PDF_VIEW_LAYOUT)}'", :type=>'button' }
    }
    args
  end

  def form_opts_no_remote url, classes='', other_html={}
    url = path(:action=>url) if Symbol===url
    opts = { :url=>url, :remote=>false, :html=>other_html }
    opts[:html][:class] = classes + ' slotter'
    opts
  end

  def load_pdf preview
    pdf_url =
      if preview
        card.pdf_preview_url Env.params[:preview_filename]
      else
        card.pdf_url
      end
    pdfjs_iframe pdf_url: pdf_url
    # if preview
    #   "<script>PDFView.open('#{card.pdf_preview_url Env.params[:preview_filename]}', 1);</script>" #unless  card.content.empty?
    #   #"<script>PDFView.open('#{card.pdf_preview_pdf_card.attach.url}', 1);</script>"
    # else
    #   "<script>PDFView.open('#{card.pdf_url}', 1);</script>" unless  card.content.empty?
    # end
  end

  def edit_button
    %{
      <a href="#" class="ui-icon ui-icon-pencil" title="Edit" onClick="javascript: window.location='/#{card.key}?view=split&layout=#{LATEX_EDIT_LAYOUT}'">
      #{ image_tag('/mod/pdfjs/images/edit.png') }
      </a>
    }
  end

  # not used, using pdfjs download button
  def download_button
    pdfcard = Card.fetch "#{card.name}+pdf"
    if pdfcard
      %{
      <a href="#" class="ui-icon ui-icon-pencil" title="Edit" onClick="javascript: window.location='/#{card.file.url}'">
      #{ image_tag('/mod/pdfjs/images/download.png') }
      </a>
    }
    end
  end

  view :header do
    voo.hide! :optional_toggle
    voo.show! :optional_title_link unless @slot_view == :open
    super()
  end

  view :split, perms: :update, tags: :unknown_ok, cache: :never do
    @split = true
    _render_edit
  end

  before :new do
    args = default_latex_new_args args
    args.merge! :nopdfview => true # disables the pdf.js toolbar
  end

  view :edit, perms: :update, tags: :unknown_ok do
    @args = {}
    default_latex_edit_args @args
    voo.show! :header
    if !@split
      _render_redirect_split
    else
      if params[:typeset] == "true" and preview_card = card.preview_card and preview_card.content.present?
        card.content = preview_card.content
      end
      voo.show :toolbar, :help
      @no_slot = true
      wrap do
      <<-HTML
        <div class="col-md-6" id="splitviewtex">
          #{super()}
          <p id="localizeerror"></p>
        </div>
        <div class="col-md-6" id="splitviewpdf">
          #{_render_edit_preview @args}
        </div>
      HTML
      end
    end
  end

  def hidden_edit_fields
    hidden_tags success: { redirect: true, view: :open, typeset: false, mark: '_self' }
  end

  def standard_frame slot=true
    super(!@no_slot)
  end

  view :edit_buttons do
    button_formgroup do
      [hidden_edit_fields, typeset_button, standard_submit_button,
       cancel_button]
    end
  end

  def typeset_button
    return unless @slot_view.to_s.eql?('split') || @args[:split] || @split
    button_tag 'Typeset',
               id: 'typeset-button',
               class: 'typeset-button btn btn-primary',
               value: 'Typeset', name: "typeset-button",
               type: 'button',
               disable_with: 'typesetting'
  end

  view :edit_preview do
    wrap do
      _render_pdf_viewer
    end
  end

  view :pdf_viewer, cache: :never do
    # %{
    # #{ ::Pdfjs.viewer }
    # #{ load_pdf args[:preview] || Env.params[:preview_filename]}
    # }
    pdf_url = nil
    if params[:success] && params[:success][:preview_filename]
      pdf_url = card.pdf_preview_url
    end
    pdf_url ||= Env.params[:preview_filename] || card.pdf_url
    pdfjs_iframe pdf_url: pdf_url

  end

  # FIXME: refactor without preview args
  # view :preview, cache: :never do
  #   unless Env.params[:preview_filename]
  #     card.new_preview_from_original
  #     Env.params[:preview_filename] = card.doc_basename
  #   end
  #   _render_open args.merge(:preview => true)
  # end

  view :editor, cache: :never do
    # At the beginning and at the end misterious newlines \r\n occur and I couldn't get rid of them
    # Switching editor to windows line break helped
    if Env.params[:card]
      card.content = Env.params[:card][:content] || card.content
    end

    output [
      text_area(:content, rows: 5,
                            class: "d0-card-content ace-editor-textarea",
                            data: { "ace-mode" => "latex", ace_theme: theme }),
      _render_tex_errors
    ]
  end

  def theme
    theme = Card.fetch(card.rule_card(:theme).content)
    theme ? theme.content : "textmate"
  end

  view :tex_errors, cache: :never do
    return '' if card.errors.empty?

    wrap do
      %{  <div class="errors-view"> <h3>Problems #{%{ with <em>#{card.name}</em>} unless card.name.blank?}</h3> } +
        card.errors.map { |attrib, msg| "<div style='text-align: left;'>#{attrib.to_s.upcase}: #{msg}</div>" } * '' +   %{
      #{ submit_tag 'Submit with errors', :class=>'submit-button btn btn-outline-secondary', :name=>"ignore_errors", :value=>"Submit with errors" }
        </div>
      }
    end
  end

  view :content_formgroup do
    if structure = card.rule(:attributes) and @slot_view.to_s.eql? "new"
      edit_form = structure.scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc|
        process_content( inc ).strip
      end.join
    else
      edit_form = edit_slot #args
    end
    %{
      <div class="card-editor editor">
        #{ edit_form }
      </div>
    }
  end

  before :open do
    voo.show :horizontal_menu
  end

  view :open_content do
    # refs = Card.fetch card.name + "+references"
    # disc_tagname = Card.fetch(:discussion, :skip_modules=>true).name
    # disc_card = unless card.new_card? or card.compound? && card.name.tag_name.key == disc_tagname.key
    #               Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    #             end

    %{
      #{_render_pdf_viewer}
      <br/>
      #{field_subformat("+pdf bottom").render_content}
    }
  end

  view :closed_content do
    ''
  end

  view :pdf_toolbar do
    %{
      <h1 class="card-header">
        <div style="float:left;">
          #{_render_title}
        </div>
        #{
          ::Pdfjs.wrap_toolbar do
          %{
            #{ edit_button if card.ok?(:update) }
            <div class="toolbarButtonSpacer"></div>
            #{_render :menu}
          }
          end
        }
      </h1>
    }
  end

  view :errors do
    if card.errors.any?
      error_msg = card.errors.map { |attrib, msg| "<div style='text-align: left;'>#{attrib.to_s.upcase}: #{msg}</div>" } * ''
      wrap do
        <<-HTML
          <div class="errors-view">
            <h2>
              Problems #{%{with <em>#{card.name}</em>} unless card.name.blank?}
            </h2>
            #{error_msg}
            #{ submit_tag 'Submit with errors',
                          :class=>'submit-button btn btn-outline-secondary',
                          :name=>"ignore_errors", :value=>"Submit with errors" }
          </div>
        HTML
      end
    end
  end

  view :redirect_split, cache: :never do
    %{
      <script> window.location = "/~#{card.id}?view=split&layout=#{LATEX_EDIT_LAYOUT}"; </script>
    }
  end

end
