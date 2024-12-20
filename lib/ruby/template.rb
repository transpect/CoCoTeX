require 'tomlib'
require 'time'
require 'json'

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

module CoCoTeX
  # this class represents the cocotex kernel template
  class Template
    attr_accessor :content,
                  :file_version,
                  :file_date,
                  :components,
                  :current

    # @param source [String] path to the template file (src/cocoTemplate.dtx)
    def initialize(source:)
      @content = source
      @current = {}
      read_version
      set_components
    end

    public
    # replaces `\includeDTX{<name>}` in the Template with the contents
    # of the corresponding `src/<name>.dtx` file
    def merge_component(name:, content:)
      @content["\\includeDTX{#{name}}"] = content
    end

    # adds the documentation preamble to the template file
    def add_preface(content:)
      @content["%% INCLUDE-DOC"] = content
    end

    # updates the mandatory argument in the macrocode environments.
    def update_code()
      @content = @content.gsub(/\\fileversion/, "v#{@file_version}")
      @content = @content.gsub(/\\filedate/, @file_date)
      @content = @content.gsub(/\\NeedsTeXFormat{LaTeX2e}\[[0-9\/]*\]/, "\\NeedsTeXFormat{LaTeX2e}[#{@min_tex_version}]")
      @content = @content.gsub(/\n%    \\begin{macrocode}[\n\s\t]*\n%    \\end{macrocode}\n/, "\n")
      @content = @content.gsub(/\n[\n]+/, "\n")
      recount_code_lines()
    end

    private
    # counts the number of lines between each `\begin{macrocode}` and
    # `\end{macrocode}` and writes the number into the mandatory
    # argument of `\begin{macrocode}`
    def recount_code_lines
      tpl = @content.split("\n")
      n = 0
      last = 0
      for line in tpl
        last = n if line =~ /begin{macrocode}/
        if line =~ /begin{macrocode}\[.+\]/
          optarg = line.scan(/^.*?\[(.+)\].*$/).first.first
          optarg = ","+optarg
        end
        if line =~ /end{macrocode}/
          nums = n - last - 1
          tpl[last] = "%    \\begin{macrocode}[lastline=#{nums}#{optarg}]"
          optarg = "" if optarg != ""
        end
        n += 1
      end
      @content = tpl.join("\n")
    end

    # collects the current date, minimal tex and file version
    # parameters from the VERSION file
    def read_version
      _f = Tomlib::load(File.read(File.join(BASE_DIR, "VERSION")))
      current = _f.to_o
      current.date.year =  Time.now.strftime("%Y")
      current.date.month = Time.now.strftime("%m")
      current.date.day =   Time.now.strftime("%d")
      @file_version = format("%s.%s.%s", current.version.major, current.version.minor, current.version.patch)
      @min_tex_version = format("%s/%s/%s",  current.tex.year, current.tex.month, current.tex.day)
      @file_date = format("%s/%s/%s", current.date.year, current.date.month, current.date.day)
      _current = current.to_h
      _current.each { |k,v| @current[k] = v.to_h }
    end

    def set_components
      @components = []
      @content.scan(/\\includeDTX\{([^\}]+)\}/) { |match| @components << match[0] }
    end
  end
end
