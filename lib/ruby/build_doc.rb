require_relative "script.rb"
module CoCoTeX
  class BuildDoc < Script
    public
    # ctor
    def initialize(options: {})
      super
      @index_script = File.join(env[LATEXBIN], "xindy")
      @doc_dir = File.join(BASE_DIR, "doc")
    end

    # @override
    def exec
      clear_temp unless @debug
      check_or_create_folders
      update_dependencies
      build_kernel
    end

    # creates the end user manual
    def create_manual
      @tex_engine = File.join(env[LATEXBIN], "lualatex")
      @doc_main = "manual"
      @doc_suffix = "tex"
      @man_src_dir = File.join(LIB_DIR, "manual")
      install_kernel
      run_while_status("Preparing Manual") do prepare_manual end
      build_manual
      create_or_exist(dir: @doc_dir)
      shell_command("mv #{@manual_out} #{@doc_dir}") if File.exists?(@manual_out)
      clear_temp unless @debug
    end

    # creates the source code documentation
    def create_doc
      @tex_engine = File.join(env[LATEXBIN], "pdflatex")
      @doc_main = "cocotex"
      @doc_suffix = "dtx"
      build_doc
      create_or_exist(dir: @doc_dir)
      shell_command("mv #{@source_doc_out} #{@doc_dir}") if File.exists?(@source_doc_out)
      clear_temp unless @debug
    end

    private
    # prepares the temporary folder for the manual
    def prepare_manual()
      manual = File.read(File.join(@man_src_dir, "cocotex.tex"))
      manual = manual.gsub(/\\fileversion/, @template.file_version).gsub(/\\filedate/, @template.file_date)
      File.open(File.join(@temp_dir, "manual.tex"), "w"){ |man| man.puts manual}
      for file in Dir.glob(File.join(@man_src_dir, "*"))
        next if file == "cocotex.tex"
        link_or_copy(file, @temp_dir)
      end
    end

    # runs LaTeX for the end usere manual
    def build_manual
      run_while_status("1st TeX run") do do_tex_run end
      run_while_status("2nd TeX run") do do_tex_run end
      run_while_status("Generating general index") do do_index end
      run_while_status("Property Index") do do_index(target: "p") end
      run_while_status("TeX Index") do do_index(target: "t") end
      run_while_status("3rd TeX run") do do_tex_run end
      run_while_status("4th TeX run") do do_tex_run end
      @manual_out = File.join(@temp_dir, "manual.pdf")
    end

    # runs LaTeX for the source code documentation
    def build_doc
      run_while_status("1st TeX run") do do_tex_run end
      run_while_status("2nd TeX run") do do_tex_run end
      run_while_status("3rd TeX run") do do_tex_run end
      @source_doc_out = File.join(@temp_dir, "cocotex.pdf")
    end

    # issues a single LaTeX run
    def do_tex_run
      o,e,s = shell_command_capture("cd #{@temp_dir} ; #{@tex_engine} #{@doc_main}.#{@doc_suffix}")
    end

    # issues a xindy run
    def do_index(target: "")
      o,e,s = shell_command_capture("cd #{@temp_dir} ; #{@index_script} #{@doc_main} #{target}")
    end


  end
end
