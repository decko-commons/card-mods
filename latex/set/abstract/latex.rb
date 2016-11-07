include LatexDocument
include_set Abstract::Pdfjs

if Card::Codename[:survey]
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

def typeset_document
  content.gsub!("\r\n","\n")
  self.content.gsub!("\r\n","\n")
  return if Env.params[:ignore_errors]
  typeset_preview content
rescue TexTypesetError => e
  errors.add 'LaTeX errors', e.message
rescue TexConfigError => e
  errors.add 'LaTeX', e.message
ensure
  if typesetting_preview? && errors.empty?
    Env.params[:success][:preview_filename] = doc_basename
    Card::Auth.as_bot do
      preview_card = Card.fetch "#{self.name}+preview",
                                new: { type: Card::PlainTextID }
      preview_card.content = self.content
      preview_card.save

      preview_pdf_card = Card.fetch "#{self.name}+preview+pdf",
                                    new: { type: Card::FileID }
      preview_pdf_card.update_attributes file: File.open(preview_pdf_path, "r")
    end
    self.content = Card.find(self).content # restore old content
    #abort :success
  end
end

def typesetting_preview?
  Env.params[:success] and Env.params[:success][:typeset] == "true"
end

def create_default_subcards
  add_subfield 'references'
  add_subfield 'discussion'
  add_subfield 'preview', content: default_tex_card.content
end

def create_default_preview
  return unless (pdf_card = default_pdf_card)
  Card::Auth.as_bot do
    preview_pdf = Card.fetch "#{name}+preview+pdf", :new => {:type => Card::FileID}
    preview_pdf.update_attributes(file: pdf_card.file.file )
  end
end

format :json do
  view :preview_path do |args|
    { src: "assets/web/viewer.html?file=#{card.pdf_preview_url}" }.to_json
  end

  view :errors do |args|
    card.format(:html)._render_tex_errors(args)
    #{ errors: card.format(:html)._render_tex_errors(args) }.to_json
  end
end

format :html do
  LATEX_EDIT_LAYOUT = "Latex_split_Layout"
  PDF_VIEW_LAYOUT = "New_Layout"

  #alias_method :original_wrap, :wrap

  def default_latex_new_args args
    args[:hidden] ||= {}
    args[:hidden][:success] = {:redirect => true, :view=>'split', :layout =>LATEX_EDIT_LAYOUT}
    args[:buttons] = %{
    #{ submit_tag 'Submit', :class=>'submit-button btn btn-primary' }
    #{ button_tag 'Cancel', :class=>'cancel-button', :onclick => "window.location.href='#{path(:view=>'open',  :id=>card.id, :layout => PDF_VIEW_LAYOUT)}'", :type=>'button' }
    }
    args
  end

  def default_latex_edit_args args
    args[:optional_help] = :show
    args[:hidden] ||= {}
    args[:hidden][:success] = {:redirect=>true,:view => 'open', :layout=>PDF_VIEW_LAYOUT, :id=>'_self'}
    args[:buttons] = %{
    #{ _render_typeset_fieldset(args) if @slot_view.to_s.eql? 'split' or args[:split]}
    #{ #load_pdf_preview if args[:split]
      }
    #{ submit_tag 'Submit', :class=>'submit-button btn btn-primary' }
    #{ button_tag 'Cancel', :class=>'cancel-button', :onclick => "window.location.href='#{path(:view=>'open',  :id=>card.id, :layout => PDF_VIEW_LAYOUT)}'", :type=>'button' }
    }
    args
  end

  # def wrap args = {}
  #   @slot_view = @current_view
  #   result = original_wrap args do
  #     yield
  #   end
  #   @slot_view = nil
  #   result
  #   #"#{result} <script>MathJax.Hub.Queue(['Typeset',MathJax.Hub]);</script>"
  # end

  def form_opts_no_remote url, classes='', other_html={}
    url = path(:action=>url) if Symbol===url
    opts = { :url=>url, :remote=>false, :html=>other_html }
    opts[:html][:class] = classes + ' slotter'
    opts[:html][:recaptcha] = 'on' if Env[:recaptcha_on] && Card.toggle( card.rule(:captcha) )
    opts
  end

  def load_pdf preview
    pdf_url =
      if preview
        card.pdf_preview_url Env.params[:preview_filename]
      else
        card.pdf_url
      end
    _render_pdfjs_iframe pdf_url: pdf_url
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
      #{ image_tag('/assets/pdfjs/images/edit.png') }
      </a>
    }
  end

  # not used, using pdfjs download button
  def download_button
    pdfcard = Card.fetch "#{card.name}+pdf"
    if pdfcard
      %{
      <a href="#" class="ui-icon ui-icon-pencil" title="Edit" onClick="javascript: window.location='/#{card.file.url}'">
      #{ image_tag('/assets/pdfjs/images/download.png') }
      </a>
    }
    end
  end


  view :header do |args|
    args[:optional_toggle] = :hide
    if @slot_view == :open
      super(args)
      #_render_pdf_toolbar args
    else
      args[:optional_title_link] = :show
      super(args) # _final_header args
    end
  end

  view :split do |args|
    _render_edit args.merge(split: true)
  end

  def default_new_args args
    args = default_latex_new_args args
    args.merge! :nopdfview => true # disables the pdf.js toolbar
  end

  view :edit do |args|
    args = default_latex_edit_args args
    #args[:split] ||= @slot_view.to_s.eql? 'split'
    if !args[:split]
      _render_redirect_split
    else
      if Env.params[:typeset] == "true" and preview_card = card.preview_card and preview_card.content.present?
        card.content = preview_card.content
        content = card.content
      end
      #_final_edit args
      <<-HTML
      <div class="col-md-6" id="splitviewtex">
        #{super(args)}
      <p id="localizeerror">
      </p>
        </div>
      <div class="col-md-6" id="splitviewpdf">
        #{_render_edit_preview args}
      </div>
      HTML
    end
  end

  view :edit_preview do |args|
    _render_pdf_viewer args
  end

  view :preview do |args|
    unless Env.params[:preview_filename]
      card.new_preview_from_original
      Env.params[:preview_filename] = card.doc_basename
    end
    _render_open args.merge(:preview => true)
  end

  view :editor do |args|
    # At the beginning and at the end misterious newlines \r\n occur and I couldn't get rid of them
    # Switching editor to windows line break helped
    if Env.params[:card]
      card.content = Env.params[:card][:content] || card.content
    end
    theme = Card.fetch(card.rule_card(:theme).content)
    theme = theme ? theme.content : "textmate"
    formid = args[:view] == "new" ? "#new_card" : "#edit_card_#{card.id}"

    # <script>
    # { load_editor_js }
    # </script>
    # %{
    # #{ Card.fetch("*load editor", :new => {}).raw_content
    # }
    #   <a name=editor></a>
    #   <div id="texeditor">#{HTMLEntities.new.encode(card.content)}</div>
    #   <script>
    #            var editor = ace.edit('texeditor');
    #            editor.getSession().setNewLineMode("windows");
    #            editor.setTheme( 'ace/theme/#{theme}' );
    #            editor.getSession().setMode('ace/mode/latex');
    #            editor.getSession().setUseWrapMode(true);
    #            $('#{formid}').submit(function (event)
    #            {
    #              $('#card_content').val(editor.getValue());
    #            });
    #            #{ if params['line'] then "editor.gotoLine(#{params['line']});" end }
    #            editor.focus();
    #   </script>
    #   #{form.hidden_field :content, :id=>"card_content", :value=>"Empty"}
    # #{ errors }
    # }
    <<-HTML
     #{text_area :content,
                 rows: 5,
                 class: 'card-content ace-editor-textarea',
                 'data-card-type-code' => card.type_code}
      #{_render_tex_errors(args)}
    HTML
  end

  view :tex_errors do |args|
    return '' if card.errors.empty?

    wrap args do
      %{  <div class="errors-view"> <h3>Problems #{%{ with <em>#{card.name}</em>} unless card.name.blank?}</h3> } +
        card.errors.map { |attrib, msg| "<div style='text-align: left;'>#{attrib.to_s.upcase}: #{msg}</div>" } * '' +   %{
      #{ submit_tag 'Submit with errors', :class=>'submit-button btn btn-default', :name=>"ignore_errors", :value=>"Submit with errors" }
        </div>
      }
    end
  end


  view :typeset_fieldset do |args |
    %{
    #{ hidden_field_tag :success_typeset, false, :name => "success[typeset]"}
    #{ button_tag 'Typeset', :id=>'typeset-button',
                             :class=>'typeset-button btn btn-primary',
                             :value=>'Typeset', :name=>"typeset-button",
                             :type=>'button' }

    }
    # <script>
    #    $('#typeset-button').click (function(){
    #        $('#success_typeset').val('true');
    #        $('#success_view').val('split');
    #        $('#success_redirect').val('false');
    #        $('#success_layout').val('#{LATEX_EDIT_LAYOUT}');
    #        $('#edit_card_#{card.id}').submit();
    #        $('#success_typeset').val('false');
    #        $('#success_view').val('open');
    #        $('#success_redirect').val('true');
    #        $('#success_layout').val('#{PDF_VIEW_LAYOUT}');
    #    });
    #  </script>
  end

  view :content_fieldsets do |args|
    if structure = card.rule(:attributes) and @slot_view.to_s.eql? "new"
      edit_form = structure.scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc|
        process_content( inc ).strip
      end.join
    else
      edit_form = edit_slot args
    end
    %{
      <div class="card-editor editor">
        #{ edit_form }
      </div>
    }
  end

  view :open_content do |args|
    # refs = Card.fetch card.name + "+references"
    # disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    # disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
    #               Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    #             end
    %{
      #{ _render_pdf_viewer args }
      <br/>
      #{ process_content_object "{{+pdf bottom|core}}"}
    }
  end

  view :closed_content do |args|
    ''
  end

  view :pdf_toolbar do |args|
    %{
      <h1 class="card-header">
        <div style="float:left;">
          #{ args.delete :toggler }
    #{ _render_title args }
        </div>
        #{
    ::Pdfjs.wrap_toolbar do
      %{
      #{ edit_button if card.ok?(:update) }
              <div class="toolbarButtonSpacer"></div>
              #{ _optional_render :menu, args}
      }
    end
    }
      </h1>
    }
  end

  view :pdf_viewer do |args|
    # %{
    # #{ ::Pdfjs.viewer }
    # #{ load_pdf args[:preview] || Env.params[:preview_filename]}
    # }
    _render_pdfjs_iframe pdf_url: args[:preview] ||
                                  Env.params[:preview_filename] || card.pdf_url
  end

  view :errors do |args|
    if card.errors.any?
      error_msg = card.errors.map { |attrib, msg| "<div style='text-align: left;'>#{attrib.to_s.upcase}: #{msg}</div>" } * ''
      wrap args do
        <<-HTML
          <div class="errors-view">
            <h2>
              Problems #{%{with <em>#{card.name}</em>} unless card.name.blank?}
            </h2>
            #{error_msg}
            #{ submit_tag 'Submit with errors',
                          :class=>'submit-button btn btn-default',
                          :name=>"ignore_errors", :value=>"Submit with errors" }
          </div>
        HTML
      end
    end
  end

  view :redirect_split do |args|
    %{
      <script> window.location = "/~#{card.id}?view=split&layout=#{LATEX_EDIT_LAYOUT}"; </script>
    }
  end
  # view :show do |args|
  #   @main_view = args[:view] || args[:home_view]
  #
  #   if @main_view.to_s.eql? 'split' or (args[:view].to_s.eql? "errors" and args[:home_view].to_s.eql? 'split')
  #     args[:layout] = LATEX_EDIT_LAYOUT
  #     args[:split] = true
  #   else
  #     args[:layout] = PDF_VIEW_LAYOUT
  #   end
  #   if ajax_call? #and not @main_view.eql? 'edit'
  #     view = @main_view || :open
  #     self.render(view, args)
  #   else
  #     self.render_layout args
  #   end
  # end

  # copy from rich_html.rb to remove edit entry from menu
  # view :menu, :tags=>:unknown_ok do |args|
  #   disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
  #   disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
  #                 Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
  #               end
  #
  #   @menu_vars = {
  #     :self         => card.name,
  #     :type         => card.type_name,
  #     :structure    => card.structure && card.template.ok?(:update) && card.template.name,
  #     :discuss      => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
  #     :piecenames   => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
  #     :related_sets => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
  #   }
  #   if card.real?
  #     @menu_vars.merge!({
  #                         :edit      => true, # pdf is the replacement for edit
  #                         :pdf_edit  => card.ok?(:update),
  #                         :account   => card.account && card.update_account_ok?,
  #                         :watch     => Account.logged_in? && render_watch(args.merge :no_wrap_comment=>true),
  #                         :creator   => card.creator.name,
  #                         :updater   => card.updater.name,
  #                         :delete    => card.ok?(:delete) && link_to( 'delete', path(:action=>:delete),
  #                                                                     :class => 'slotter standard-delete', :remote => true, :'data-confirm' => "Are you sure you want to delete #{card.name}?"
  #                         )
  #                       })
  #   end
  #
  #   json = html_escape_except_quotes JSON( @menu_vars )
  #   %{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
  # end
end