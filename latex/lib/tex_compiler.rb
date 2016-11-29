# -*- encoding : utf-8 -*-

class TexCompiler
  class << self
    def format_home;  Wagn.paths['fmt'].first  end

    def run_latex path, tex_filename, format_filename
      Rails.logger.debug("Run latex for #{tex_filename} with format #{format_filename} in #{path}.")
      Rails.logger.debug("cd #{path}; #{ latex_cmd( tex_filename, format_filename ) }")
      return system("cd #{path}; #{ latex_cmd( tex_filename, format_filename ) } ")
    end

    def run_bibtex path, tex_filename
      Rails.logger.debug("Run bibtex for #{tex_filename} in #{path}")
      return system("cd #{path}; #{bibtex_cmd tex_filename}")
    end

    def run_initex format_path, format_filename
      Rails.logger.debug("Run initex for #{format_filename} in #{format_path}")
      return system("cd #{format_path}; #{initex_cmd format_filename}")
    end

    def parse_logfile full_path, name, logname
      Rails.logger.debug("Parse logfile for #{name} in #{full_path}")
      return `python \"#{Wagn.paths['script'].first}/wagntexparser.py\" '#{full_path}' '#{name}' '#{logname}'`
    end

    def latex_cmd tex_filename, format_filename   # filenames without ending
      "pdfetex -output-format pdf -interaction=batchmode -file-line-error -synctex=0 -fmt '#{format_filename}'  './#{tex_filename}.tex'"
    end

    def initex_cmd format_filename                # filename without ending
      "pdfetex '-ini' '-interaction=batchmode' '-file-line-error' '&pdflatex' './#{format_filename}.ini'"
    end

    def bibtex_cmd tex_filename                   # filename without ending
      "bibtex './#{tex_filename}'"
    end
  end


  def initialize tex_card
    @tex_card = tex_card
  end

  # create pdf file
  def pdflatex log=true
    format_path = File.join TexCompiler.format_home, @tex_card.format_name
    result = TexCompiler.run_latex @tex_card.home, @tex_card.doc_basename, format_path
    if not result
      raise   TexTypesetError, parse_logfile
    end

    if log and File.exists? @tex_card.log_path
      @tex_card.update_log_card File.read(@tex_card.log_path)
    end
  end

  # create bibliography
  def bibtex
    TexCompiler.run_bibtex @tex_card.home, @tex_card.doc_basename
  end

  # create format file
  def initex
    unless TexCompiler.run_initex TexCompiler.format_home,
                                  @tex_card.format_name
      raise TexTypesetError, parse_logfile
    end
  end

  def parse_logfile
    TexCompiler.parse_logfile @tex_card.log_path, @tex_card.doc_basename, @tex_card.log_cardname
  end
end
