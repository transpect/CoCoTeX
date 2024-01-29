class Thor

  # Adjust format of help pages
  def self.help(shell, subcommand = false)
    list = printable_commands(true, subcommand)
    Thor::Util.thor_classes_in(self).each do |klass|
      list += klass.printable_commands(false)
    end
    for l in list
      l[0] = format("%-#{23}s", l[0])
    end
    sort_commands!(list)

    if defined?(@package_name) && @package_name
      shell.say "#{@package_name} commands:"
    else
      shell.say "Commands:"
    end
    shell.say
    shell.print_table(list, indent: 2, truncate: true)
    shell.say
    shell.say
    class_options_help(shell)
    print_exclusive_options(shell)
    print_at_least_one_required_options(shell)
  end

  # Adjust format of printable commands
  def self.printable_commands(all = true, subcommand = false)
    (all ? all_commands : commands).map do |_, command|
      next if command.hidden?
      item = []
      item << banner(command, false, subcommand)
      item << (command.description ? "  #{command.description.gsub(/\s+/m, ' ')}" : "")
      item
    end.compact
  end

  def self.banner(command, namespace = nil, subcommand = false)
    command.formatted_usage(self, $thor_runner, subcommand).split("\n").map do |formatted_usage|
      "cocotex.sh #{formatted_usage}"
    end.join("\n")
  end

  def self.command_help(shell, command_name)
    meth = normalize_command_name(command_name)
    command = all_commands[meth]
    handle_no_command_error(meth) unless command

    shell.say "Usage:"
    shell.say "  #{banner(command).split("\n").join("\n  ")}"
    shell.say
    shell.say
    shell.say
    class_options_help(shell, nil => command.options.values)
    print_exclusive_options(shell, command)
    print_at_least_one_required_options(shell, command)

    if command.long_description
      shell.say "Description:"
      if command.wrap_long_description
        shell.print_wrapped(command.long_description, indent: 2)
      else
        shell.say command.long_description
      end
    else
      shell.say command.description
    end
  end

  # Generally suppress automatic generation of --no-boolean, cf. https://github.com/rails/thor/pull/733
  class Option < Argument
    def usage(padding = 0)
      sample = if banner && !banner.to_s.empty? then "#{switch_name}=#{banner}".dup ; else switch_name; end
      sample = "[#{sample}]".dup unless required?
      #if boolean?
      #  sample << ", [#{dasherize('no-' + human_name)}]" unless (name == "force") || name.match(/\Ano[\-_]/) || 
      #end
      aliases_for_usage.ljust(padding) + sample
    end
  end
  # Receives a set of options and print them.
  module Base::ClassMethods
    def print_options(shell, options, group_name = nil)
      return if options.empty?

      list = []
      padding = options.map { |o| o.aliases_for_usage.size }.max.to_i
      options.each do |option|
        next if option.hide
        item = [format("%-#{25}s", option.usage(8).sub("[", "").sub("]", ""))]
        item.push(option.description ? "#{option.description}" : "")
        list << item

        if option.show_default? or option.enum
          str = "  ("
          str += "possible values: #{option.enum_to_s}" if option.enum
          str += "; " if option.show_default? and option.enum
          str += "default: #{option.print_default}" if option.show_default?
          list << ["", str + ")"]
        end
      end

      shell.say(group_name ? "#{group_name} options:" : "Options:")
      shell.print_table(list, indent: 2)
      shell.say ""
    end
  end
end

## fix for sub-commands, cf. https://github.com/rails/thor/wiki/Subcommands#subcommands-that-work-correctly-with-help
class SubCommandBase < Thor
  def self.banner(command, namespace = nil, subcommand = false)
    "cocotex.sh #{subcommand_prefix} #{command.usage} "
  end

  def self.subcommand_prefix
    self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
  end
end
