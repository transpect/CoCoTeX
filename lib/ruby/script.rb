# coding: utf-8
require 'pathname'
require 'ostruct'
require 'open3'
require 'time'
require 'io/console'

module CoCoTeX

  class Script

    # ctor
    #
    # @param options [Array<String>] options from the CLI
    def initialize(options: {})
      @options = OpenStruct.new(options)
      @current_path = Pathname.new(ENV["CUR_PWD"])
      @temp_dir = @options.temp_dir
      @log_dir = @options.log_dir
      @log_path = File.join(@log_dir, @options.log_file) if @options.log_file
      @test_mode = true if @options.test
      @debug = true if @options.debug == 'debug'
      @verbose = true if @options.verbose
      @color = true unless @options.no_color
      @user = `whoami`.gsub(/\n/, "")
      File.umask(0002)
      clear_temp
    end

    # @abstract
    def exec
      raise StandardError.new "Method #{$log.color_str("Script::exec()")} is abstract."
    end

    protected
    # Runs a shell command and returns its exit status. It also
    #   processes the +@options.test+ (+cmd+ is displayed as text
    #   instead of being executed) and +@options.silent+ (supresses
    #   shell output completely) options. See +check_shell_command+
    #   for further details.
    #
    # @param cmd [String] shell command
    # @param use_test [Boolean] if non-nil, run +cmd+ even when `--test`
    #   is set, but send the value of +use_test+ to +cmd+ if it is a string.
    # @param ignore_test [Boolean] if true, ignore `--test` (i.e. run
    #   +cmd+ under all circumstances)
    # @return [Integer] Exit status of +cmd+
    def shell_command(cmd, use_test: false, ignore_test: false, silent: false)
      _cmd = check_shell_command(cmd, use_test: use_test, ignore_test: ignore_test)
      stat = nil
      Open3.popen2e("umask 002 ; #{_cmd}") { |i, oe, s|
        pid = s.pid
        while line = oe.gets
          puts "#{line}" unless silent
        end
        stat = s.value.exitstatus
      }
      return stat
    end

    # Runs a shell command and returns its exit status, its std::out,
    #   and std::err output. It also processes the +@options.test+
    #   (+cmd+ is displayed as text instead of being executed) and
    #   +@options.silent+ (supresses shell output completely)
    #   options. See +check_shell_command+ for further details.
    #
    # @param cmd [String] shell command
    # @param use_test [Boolean] if non-nil, run +cmd+ even when `--test`
    #   is set, but send the value of +use_test+ to +cmd+ if it is a string.
    # @param ignore_test [Boolean] if true, ignore `--test` (i.e. run
    #   +cmd+ under all circumstances)
    # @return [String, String, ] Exit-Status von +cmd+
    def shell_command_capture(cmd, use_test: false, ignore_test: false)
      _cmd = check_shell_command(cmd, use_test: use_test, ignore_test: ignore_test)
      o,e,s = Open3.capture3("umask 002 ; #{_cmd}")
      return o,e,s
    end

    # Manipulates shell commands depending on set options.
    #
    #   If the option `--test` is set, check first if the caller has
    #   given an override for that case. If no override is given,
    #   return either `cmd` with an additional `--test` parameter, or
    #   replace cmd with `sleep 0.001`.
    #
    #  If --test is not given by the user, return cmd.
    #
    # @param cmd [String] initial shell command
    # @param use_test [Boolean] if non-nil, run +cmd+ even when `--test`
    #   is set, but send the value of +use_test+ to +cmd+ if it is a string.
    # @param ignore_test [Boolean] if true, ignore `--test` (i.e. run
    #   +cmd+ under all circumstances)
    #
    # @return [String] (manipulated) shell command
    def check_shell_command(cmd, use_test: false, ignore_test: false)
      if @options.test && !ignore_test
        puts format("\033[1m\033[96m%-14s\033[21m umask 002 ; %s\033[0m", "[Test-Cmd]", cmd.to_s) unless @options.silent
        return use_test ? "#{cmd} --test" : "sleep 0.001"
      end
      return cmd
    end

    # Executes `yield` while a message is displayed.
    #
    # @param str [String] Message that should be displayed while body is processed
    # @param log_level [String] log level of the displayed message
    # @yield list of instructions
    def run_while_status(str, log_level: "info")
      col = $log.format_color(log_level)
      print Kernel::sprintf("%-#{@color ? "26" : "15"}s%-72s", col, str)
      yield
      puts Kernel::sprintf(" [%#{@color ? "15" : "4"}s]", $log.color_str("done", color: 32))
    end

    # iterates through a list while printing a status message with a
    # percentile.
    #
    # @param array [Array] list that should be iterated
    # @param str [String] status message
    # @option with_count [Boolean] whether "progress/total" should be displayed, default: false
    # @option log_level [String] log level sent to +AbLogger::color_<str>+, default: "info"
    def loop_with_status(array, str, with_count = false, log_level = "info")
      _cnt = 0
      _len = array.length
      col = $log.format_color(log_level)
      for element in array
        _cnt += 1
        t = (_cnt/(_len*0.01)).round
        d_cnt = with_count ? format("(%i/%i, %i%%)", _cnt, _len, t) : "(#{t.to_s}%)"
        print Kernel::sprintf("%-#{@color ? "26" : "15"}s%s %s.", col, str, d_cnt)
        print "\r" if _cnt < _len
        yield(element)
      end
      puts ""
    end

    # prints self
    def debug_inspect()
      if @debug
        $log.debug("Object output:")
        pp self
      end
    end

    # creates a directory if that doesn't exist, yet
    def create_or_exist(dir:)
      unless Dir.exists?(dir)
        shell_command("mkdir --parents #{dir}", ignore_test: true)
      end
    end

    # clears the temporary folder given by the --temp option
    def clear_temp
      return if @debug or @options.keep_temp or !Dir.exists?(@temp_dir)
      shell_command("rm -rf #{@temp_dir} ")
    end
  end
end
