# -*- coding: utf-8 -*-

require 'logger'

# Wrapper for the Ruby logger
class CoCoLogger
  attr_accessor :logger,#skriptspezifische Logger-Instanz für .log-Dateien
  :stdout,#Loggerinstanz für Shell-Output
  :issuer,
  :color

  # Konstruktor
  def initialize()
    @issuer = nil
    @stdout = Logger.new(STDOUT)
  end

  def set_color(color: true)
    @color = color
  end

  def newline
    @stdout.unknown("\n")
  end

  # Initialisiert den Ruby-Logger für die log-Datei-Ausgabe
  #
  # @param level [String] default Level
  # @param issuer [String] Name der log-Datei
  def set_logger(level: , issuer: )
    @stdout.level = level
    log_dir = File.dirname(issuer)
    unless File.directory?(log_dir)
      warn("#{log_dir} existiert nicht, lege an. Bitte das .log-Verzeichnis NICHT mit ins git-Repo packen (nicht mit adden oder direkt in die .gitignore)!")
      `mkdir -p #{log_dir}`
    end
    @logger = Logger.new(issuer,5,64*1024*1024)# max 5 Dateien à 64MB
    set_shell_format()
    set_logfile_format()
  end

  # erzeugt eine fatale Fehlermeldung und bricht die weitere
  #   Skriptausführung ab. Parameter-Struktur siehe +write_log+
  def fatal(msg, no_log = false)
    write_log("fatal", msg, no_log)
    exit(1)
  end

  # erzeugt eine Fehlermeldung, lässt das restliche Skript aber
  #   weiterlaufen. Parameter-Struktur siehe +write_log+
  def error(msg, no_log = false)
    write_log("error", msg, no_log)
  end

  # erzeugt eine Warnung. Parameter-Struktur siehe +write_log+
  def warn(msg, no_log = false)
    write_log("warn", msg, no_log)
  end

  # erzeugt eine Debug-Nachricht. Parameter-Struktur siehe +write_log+
  def debug(msg, no_log = false)
    write_log("debug", msg, no_log)
  end

  # erzeugt eine allgemeine Nachricht. Parameter-Struktur siehe
  #   +write_log+
  def info(msg, no_log = false)
    write_log("info", msg, no_log)
  end

  # Packt Farbinformationen um die Severity-Strings, falls die Option
  #   +--color+ gesetzt ist (default). Andernfalls wird der String ohne
  #   Farben ausgegeben.
  #
  # @param str [String] code der an color_<str> übergeben wird
  def format_color(str)
    col = self.send("color_#{str}")
    if @color
      return "[\033[1;#{col[1]}m#{col[0]}\033[0m]"
    else
      return "[#{col[0]}]"
    end
  end

  #fork of CoCoTeX::Scripts::Script.color_str()
  def color_str(str, color: 33)
    return @color ? "\033[0;#{color.to_s}m#{str}\033[0m" : str
  end

  private
  # schreibt log-Nachricht in die log-Datei und in die Konsole
  #
  # @param level [String] Logger-Level
  # @param msg [String] Log-Nachricht
  # @param no_log [Boolean] Wenn true, kein Eintrag in die Log-Dateien, sondern nur in die Konsole
  def write_log(level, msg, no_log)
    @logger.send(level,msg) if @logger && !no_log
    @stdout.send(level,msg)
  end

  # Legt fest, wie die Ausgabe in die Konsole formatiert werden soll
  def set_shell_format
    @stdout.formatter = proc do |severity, datetime, progname, msg|
      case severity
      when "FATAL"
        srv = format_color("fatal")
      when "ERROR"
        srv = format_color("error")
      when "WARN"
        srv = format_color("warn")
      when "INFO"
        srv = format_color("info")
      when "DEBUG"
        srv = format_color("debug")
      else
        srv = ""
      end
      @color ? format("%-26s%s\n",srv,msg) : format("%-15s%s\n",srv,msg)
    end
  end

  def color_fatal; return ["Fatal Error",  31]; end
  def color_error; return ["Error",  31]; end
  def color_warn;  return ["Warning", 33]; end
  def color_info;  return ["Info",    32]; end
  def color_debug; return ["Debug",   34]; end

  # Legt fest, wie die Ausgabe in die log-Dateien formatiert werden soll
  def set_logfile_format
    @logger.formatter = proc do |severity, datetime, progname, msg|
      log_prefix = datetime.strftime("%Y-%m-%d %H:%M:%S")
      "[#{log_prefix.ljust(19)} #{severity.ljust(5)}] #{msg}\n"
    end
  end
end

$log = CoCoLogger.new()
