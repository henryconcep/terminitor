module Terminitor
  module Runner

    # opens doc in system designated editor
    def open_in_editor(path)
      `#{ENV['EDITOR']} #{path}`
    end

    def do_project(project)
      terminal = app('Terminal')
      tabs = load_config(project)
      tabs.each do |hash|
        tabname = hash.keys.first
        cmds = hash.values.first

        tab = self.open_tab(terminal)
        cmds = [cmds].flatten
        cmds.each do |cmd|
          terminal.windows.last.do_script(cmd, :in => tab)
        end
      end
    end

    # def usage
    #   puts "
    #   Usage:
    #   #{File.basename(@file)} project_name
    #   where project_name is the name of a terminit project yaml file
    # 
    #   See the README for more information.
    #   "
    #   exit 0
    # end

    def load_config(project)
      path = File.join(ENV['HOME'],'.terminitor', "#{project.sub(/\.yml$/, '')}.yml")
      return false unless File.exists?(path)
      YAML.load(File.read(path))
    end

    # somewhat hacky in that it requires Terminal to exist,
    # which it would if we run this script from a Terminal,
    # but it won't work if called e.g. from cron.
    # The latter case would just require us to open a Terminal
    # using do_script() first with no :in target.
    #
    # One more hack:  if we're getting the first tab, we return
    # the term window's only current tab, else we send a CMD+T
    def open_tab(terminal)
      window =  has_visor? ? 2 : 1
      if @got_first_tab_already
        app("System Events").application_processes["Terminal.app"].keystroke("t", :using => :command_down)
      end
      @got_first_tab_already = true
      local_window = terminal.windows[window]
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end
    
    # checks to see if the user has Visor installed
    def has_visor?
      File.exists?("#{ENV['HOME']}/Library/Application\ Support/SIMBL/Plugins/Visor.bundle/")
    end
    
  end
end
