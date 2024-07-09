require_relative "build.rb"
require "tempfile"
require "fileutils"
module CoCoTeX
  class BuildDoc <  Build
    public
    # ctor
    def initialize(options: {})
      super
      @tex_engine = File.join(ENV["LATEXBIN"], "lualatex")
      @doc_dir = resolve_path(@options.out)
    end

    # @override
    def exec
      clear_temp unless @options.quick
      check_or_create_folders
      build_kernel
    end

    # creates the end user manual
    def create_manual
      @doc_main = "manual"
      @doc_suffix = "tex"
      @man_src_dir = File.join(LIB_DIR, "manual")
      $log.info("Generating end-user manual")
      install_kernel
      prepare_manual
      prepare_doc
      build_manual
      create_or_exist(dir: @doc_dir)
      shell_command("mv #{@manual_out} #{@doc_dir}") if File.exists?(@manual_out)
      clear_temp unless @debug or @options.quick
    end

    # creates the source code documentation
    def create_doc
      @doc_main = "cocotex"
      @doc_suffix = "dtx"
      $log.info("Generating source code documentation")
      prepare_doc
      build_doc
      create_or_exist(dir: @doc_dir)
      shell_command("mv #{@source_doc_out} #{@doc_dir}") if File.exists?(@source_doc_out)
      clear_temp unless @debug or @options.quick
    end

    private
    # prepare the temporary folder for source code doc generation
    def prepare_doc
      ist_file = File.join(LIB_DIR, "doc", "cocotex.ist")
      shell_command("cp #{ist_file} #{@temp_dir}")
    end

    # prepares the temporary folder for the manual
    def prepare_manual
      manual = File.read(File.join(@man_src_dir, "cocotex.tex"))
      manual = manual.gsub(/\\fileversion/, @template.file_version).gsub(/\\filedate/, @template.file_date)
      File.open(File.join(@temp_dir, "manual.tex"), "w"){ |man| man.puts manual}
      for file in Dir.glob(File.join(@man_src_dir, "*"))
        next if file == "cocotex.tex"
        shell_command("cp -r #{file} #{@temp_dir}")
      end
      resolve_dependencies
    end

    # runs LaTeX for the end usere manual
    def build_manual
      run_while_status("1st TeX run") do do_tex_run end
      unless @options.quick
        run_while_status("2nd TeX run") do do_tex_run end
        run_while_status("3rd TeX run") do do_tex_run end
        run_while_status("Generating Index") do do_makeindex() end
        run_while_status("4th TeX run") do do_tex_run end
        run_while_status("5th TeX run") do do_tex_run end
      end
      @manual_out = File.join(@temp_dir, "manual.pdf")
    end

    # runs LaTeX for the source code documentation
    def build_doc
      run_while_status("1st TeX run") do do_tex_run end
      unless @options.quick
        run_while_status("2nd TeX run") do do_tex_run end
        run_while_status("3rd TeX run") do do_tex_run end
        run_while_status("Generating Index") do do_makeindex() end
        run_while_status("4th TeX run") do do_tex_run end
        run_while_status("5th TeX run") do do_tex_run end
      end
      @source_doc_out = File.join(@temp_dir, "cocotex.pdf")
    end

    def resolve_dependencies
      return if @options.quick
      shell_command("cd #{@temp_dir} ; ln -s #{File.join(EXT_DIR, "htmltabs", "htmltabs.sty")} .") unless File.exists?(File.join(@temp_dir, "htmltabs.sty"))
      xf = resolve_path(@options.xerif_fonts) if @options.xerif_fonts
      if xf && Dir.exists?(xf)
        $log.info("using #{xf}.")
        shell_command("cd #{@temp_dir} ; ln -s #{xf} fonts")
      else
        $log.info("Collecting xerif-fonts (this may take a while, you can checkout the svn repo yourself and use the --xerif-fonts option to specify the path to the fonts)")
        o,e,s = shell_command_capture("cd #{@temp_dir} ; svn co https://subversion.le-tex.de/common/xerif-fonts/ fonts")
        unless s.success?
          $log.newline
          $log.error(e)
        end
      end
    end

    def do_makeindex(manual: false)
      makeindex = File.join(ENV["LATEXBIN"], "makeindex")
      raw_index_file = File.join(@temp_dir, "#{@doc_main}.idx")
      preprocess_idx(index: raw_index_file, manual: manual)
      cmd = "cd #{@temp_dir} ; splitindex #{@doc_main}.idx -- -s cocotex.ist"
      _cmd = check_shell_command(cmd)
      st = nil
      err = ""
      Open3.popen2e("umask 002 ; #{_cmd}") do |i,o,s|
        cnt = 0
        o.each do |l|
          if @options.debug == "debug"
            puts l
          else
            if l =~ /, [^0]+ rejected\)./
              err += l
              cnt = cnt - 1
            end
          end
        end
        if err != ""
          raise StandardError.new("Makeindex error #{err}")
        end
      end
    end

    def preprocess_idx(index: ,manual: false)
      temp = Tempfile.new('tempindex.idx')
      File.open(index, "r") do |f|
        f.each_line do |line|
          if manual
            temp.puts(line.gsub(/\\indexentry\[manual\]{cc[a-z]?@?/, '\\indexentry[manual]{'))
          else
            temp.puts(line.gsub(/\\indexentry\[cocotex\]{cc[a-z]?@?/, '\\indexentry[cocotex]{'))
          end
        end
      end
      temp.close
      FileUtils.mv(temp.path, index)
    end


    # issues a single LaTeX run
    def do_tex_run
      cmd = "cd #{@temp_dir} ; #{@tex_engine} -interaction=nonstopmode #{@doc_main}.#{@doc_suffix}"
      _cmd = check_shell_command(cmd)
      st = nil
      err = ""
      Open3.popen2e("umask 002 ; #{_cmd}") do |i,o,s|
        cnt = 0
        o.each do |l|
          if @options.debug == "debug"
            puts l
          else
            if l =~ /^! /
              cnt = 3
            end
            if cnt != 0
              err += l
              cnt = cnt - 1
            end
          end
        end
        if err != ""
          raise StandardError.new("LaTeX error #{err}")
        end
      end
    end



  end
end
