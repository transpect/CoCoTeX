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
                  :new_version

    # @param source [String] path to the template file (src/cocoTemplate.dtx)
    def initialize(source:)
      @content = source
      update_template
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
      @content = @content.gsub(/\\fileversion/, @file_version)
      @content = @content.gsub(/\\filedate/, @file_date)
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

    # determins the current time and file version and compares it with the values stored in the VERSION file in the base directory
    def update_template
      file_version = @content.match(/\\def\\fileversion\{([^}]+)\}/)[1]
      _f = Tomlib::load(File.read(File.join(BASE_DIR, "VERSION")))
      current = _f.to_o
      if file_version != format("%s.%s.%s", current.version.major, current.version.minor, current.version.patch)
        toml = OpenStruct.new()
        toml.version = OpenStruct.new()
        toml.date = OpenStruct.new()
        toml.version.major,toml.version.minor,toml.version.patch = file_version.split(".")
        toml.date.year =  Time.now.strftime("%Y")
        toml.date.month = Time.now.strftime("%m")
        toml.date.day =   Time.now.strftime("%d")
        @file_version = file_version
        @file_date = format("%s/%s/%s", toml.date.year, toml.date.month, toml.date.day)
        @new_version = {"version" =>
                        {"major" => toml.version.major,
                         "minor" => toml.version.minor,
                         "patch" => toml.version.patch},
                        "date" =>
                        {"year" => toml.date.year,
                         "month" => toml.date.month,
                         "day" => toml.date.day
                        }}
      else
        @file_version = format("%s.%s.%s", current.version.major, current.version.minor, current.version.patch)
        @file_date = format("%s/%s/%s", current.date.year, current.date.month, current.date.day)
        @new_version = nil
      end
      #@file_date = Time.now.strftime("%Y/%m/%d")
      @content = @content.gsub(/\\def\\fileversion\{([^}]+)\}/, "")
    end

    def set_components
      @components = []
      @content.scan(/\\includeDTX\{([^\}]+)\}/) { |match| @components << match[0] }
    end
  end
end
