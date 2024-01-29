require_relative "build_doc.rb"

module CoCoTeX
  class Doc < SubCommandBase

    private
    def create_doc(options: )
      require File.join(SCRIPT_DIR, "doc.rb")
      @doc = BuildDoc.new(options: options)
      @doc.exec
    end

    public
    desc "all", "Creates both end-user manual and source code documentation"
    def all()
      create_doc(options: options)
      @doc.create_manual
      @doc.create_doc
    end

    desc "manual", "Creates only the end-user manual"
    def manual()
      create_doc(options: options)
      @doc.create_manual
    end

    desc "source", "Creates only the source code documentation"
    def source()
      create_doc(options: options)
      @doc.create_doc
    end

    default_task :all
  end
end
