require 'bundler/setup'
require 'dry/cli'
require 'dry/cli/utils/files'

require 'listen'

require 'aspen'
require 'aspen/watcher'

module Aspen
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc "Print version"

        def call(*)
          puts Aspen::VERSION
        end
      end

      class Compile < Dry::CLI::Command
        desc "Compile an Aspen file to Cypher (in the same directory)"

        argument :path, required: true, desc: "Aspen file to compile to Cypher"

        example [
          "path/to/file.aspen # Compiles to path/to/file.cypher"
        ]

        def call(path: )
          basename = File.basename(path, ".aspen")
          dir = File.dirname(path)
          dest = File.expand_path("#{basename}.cql", dir)
          File.open(dest, 'w') do |file|
            file << Aspen.compile_text(File.read(path))
          end

          puts "Compiled #{basename}.aspen to #{basename}.cql."
        end
      end

      module Watch
        class Run < Dry::CLI::Command
          desc "Watch a single file and automatically compile it"

          argument :path, required: true

          def call(path: )
            Aspen::Watcher.new(path: path).start
          end
        end
      end

      # module Server
      #   class Start < Dry::CLI::Command
      #     desc "Start Aspen server in the background"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Stop < Dry::CLI::Command
      #     desc "Stop Aspen server"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Run < Dry::CLI::Command
      #     desc "Run Aspen server in the foreground"
      #     def call()
      #       # NO OP
      #     end
      #   end
      # end

      class New < Dry::CLI::Command
        desc "Generate files for a new Aspen project"

        argument :name,
          desc: "Name for new Aspen project folder",
          required: true

        def call(name: )
          Dry::CLI::Utils::Files.mkdir(name)
          # This should be re-added only when discourses
          # can be written as a special discourse file.
          # Dry::CLI::Utils::Files.mkdir("#{name}/discourses")
          Dry::CLI::Utils::Files.mkdir("#{name}/narratives")
          Dry::CLI::Utils::Files.touch("#{name}/narratives/#{name}.aspen")

          # In a project, Aspen might be built into a set of Cypher files
          # or perhaps a single master Cypher file.
          Dry::CLI::Utils::Files.mkdir("#{name}/build")

          puts "Generated new project '#{name}'"
        end
      end

      # module Generate
      #   class Discourse < Dry::CLI::Command
      #     desc "Generate a new discourse within a project"
      #     def call()
      #       # NO OP
      #     end
      #   end

      #   class Narrative < Dry::CLI::Command
      #     desc "Generate a new narrative within a project"
      #     def call()
      #       # NO OP
      #     end
      #   end
      # end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "compile", Compile, aliases: ["c"]

      register "watch", Watch::Run, aliases: ["w"]

      # register "new", New

      # register "generate", aliases: ["g"] do |prefix|
      #   prefix.register "discourse", Generate::Discourse
      #   prefix.register "narrative", Generate::Narrative
      # end

      # register "server", aliases: ["s"] do |prefix|
      #   prefix.register "run",   Server::Run
      #   prefix.register "start", Server::Start
      #   prefix.register "stop",  Server::Stop
      # end
    end
  end
end
