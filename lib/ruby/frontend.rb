require 'thor'

BASE_DIR = ENV["COCOTEX_SRC"]
LIB_DIR = File.join(BASE_DIR, "lib")
RUBY_DIR = File.join(LIB_DIR, "ruby")
EXT_DIR = File.join(BASE_DIR, "externals")
require File.join(RUBY_DIR, "logger.rb")
UTIL_DIR = File.join(RUBY_DIR, "utils")
require File.join(RUBY_DIR, 'thor_hacks.rb')
require File.join(RUBY_DIR, 'doc.rb')
DEFAULT_TEMP_DIR = File.join(BASE_DIR, 'temp')
DEFAULT_LOG_DIR = File.join(BASE_DIR, 'log')
DEFAULT_OUT_DIR = File.join(BASE_DIR, 'build')
DEFAULT_DOC_DIR = File.join(BASE_DIR, 'doc')

module CoCoTeX
  class Frontend < Thor
    package_name "CoCoTeX Kernel build script"

    def self.exit_on_failure?; true; end

    # overridden ctor to mix in logging functionalities
    def initialize(*argv)
      super(*argv)
      if options[:log_file]
        log_file = options[:log_file]
      else
        log_file = "debug.log"
      end
      log_file = File.join(options[:log_dir], log_file)
      $log.set_logger(level: options[:debug], issuer: log_file)
      $log.set_color(color: !options[:no_color])
      $log.stdout.level = "FATAL" if options[:silent]
    end
    check_unknown_options!

    class_option :temp_dir, type: :string, required: false, desc: "path to directory where temporary files should be stored", default: DEFAULT_TEMP_DIR, group: "Path", banner: "PATH"
    class_option :log_dir, type: :string, required: false, desc: "path to the directory where log files should be stored", default: DEFAULT_LOG_DIR, group: "Path", banner: "PATH"
    class_option :debug, aliases: :d, type: :string, required: false, desc: "Debug level.", enum: ["debug", "info", "warn", "error", "fatal"], default: "info", group: "Output", banner: "LEVEL"
    class_option :no_color, aliases: :c, type: :boolean, required: false, desc: "Status messages are printed without colours", group: "Output"
    class_option :version, aliases: :V, type: :boolean, required: false, desc: "prints Version", group: "Other"
    class_option :keep_temp, aliases: :k, type: :boolean, required: false, desc: "if set, temporary files and folders are kept", group: "Other"

    desc "build", "Builds .sty and other files from .dtx sources"
    long_desc "This command unpacks the .dtx files of the various CoCoTeX sources and generates the style and other projet files."
    option :log_file, required: false, desc: "path to the log file", default: "build", group: "Output", banner: "PATH"
    option :out, aliases: :o, type: :string, required: false, desc: "output directory", group: "Output", default: DEFAULT_OUT_DIR
    def build()
      # $log.fatal("Building styles") ; exit(1)
      require File.join(RUBY_DIR, "build.rb")
      puts options.inspect if options[:test]
      build = CoCoTeX::Build.new(options: options)
      build.exec
    end

    # script with sub-commands to build the source code
    #   documentation and the user manual
    desc "doc  [SUB-COMMAND]", "Creates the documentations, see 'doc help' for more information"
    long_desc "This command creates the source code documentation of the CoCoTeX framework, the end user manual, or both."
    option :log_file, required: false, desc: "path to the log file", default: "doc", banner: "PATH"
    option :out, aliases: :o, type: :string, required: false, desc: "output directory", group: "Output", default: DEFAULT_DOC_DIR
    option :xerif_fonts, aliases: :f, type: :string, required: false, desc: "Path to the xerif-fonts repo", group: "Input", default: nil
    option :quick, aliases: :q, type: :boolean, required: false, desc: "do only one single LaTeX run", group: "Other", default: false
    subcommand "doc", Doc

    default_task :build
  end
end

$cur_date = Time.now.strftime("%Y/%m/%d")
cocotex_script = CoCoTeX::Frontend.start(ARGV)
