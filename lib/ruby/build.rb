require 'tomlib'
require File.join(RUBY_DIR, 'script.rb')
require File.join(RUBY_DIR, 'template.rb')


module CoCoTeX
  class Build < Script
    #ctor
    def initialize(options: {})
      super
      @source_dir = File.join(BASE_DIR, "src")
      @out_dir = resolve_path(@options.out)
    end

    def exec
      clear_temp
      check_or_create_folders
      build_kernel
      install_kernel
      move_kernel
      clear_temp
    end

    private
    def check_or_create_folders
      create_or_exist(dir: @temp_dir)
      create_or_exist(dir: @out_dir)
    end

    def build_kernel
      _template_content = File.read(File.join(@source_dir, "cocoTemplate.dtx"))
      @template = CoCoTeX::Template.new(source: _template_content)
      for component in @template.components
        comp_path = File.join(@source_dir, "#{component}.dtx")
        if File.exist?(comp_path)
          @template.merge_component(name: component, content: File.read(comp_path))
        else
          $log.fatal("Source file #{color_str(comp_path)} not found! Aborting!")
        end
      end
      @template.add_preface(content: File.read(File.join(@source_dir, "cocoDTXPreface.dtx")))
      File.open(File.join(BASE_DIR, "VERSION"), "w") { |file| file.puts Tomlib::dump(@template.current) }
      @template.update_code()
      File.open(File.join(@temp_dir, "cocotex.dtx"), "w") { |file| file.puts @template.content }
    end

    def install_kernel
      run_while_status("Building CoCoTeX v#{@template.file_version}, #{@template.file_date}") do
        shell_command(format("cd #{@temp_dir}; cp %s .", File.join(LIB_DIR, "install", "cocotex.ins")))
        shell_command("cd #{@temp_dir}; latex cocotex.ins", silent: true)
      end
    end

    def move_kernel
      shell_command("mv #{File.join(@temp_dir, "cocotex.cls")} #{@out_dir}")
      shell_command("mv #{File.join(@temp_dir, "coco-*.sty")} #{@out_dir}")
      shell_command("mv #{File.join(@temp_dir, "coco-*.lua")} #{@out_dir}")
    end
  end
end
