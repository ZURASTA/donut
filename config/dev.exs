use Mix.Config

import_config "simple_markdown_rules.exs"

config :simple_markdown_extension_highlight_js,
    source: Enum.at(Path.wildcard(Path.join(Mix.Project.deps_path(), "ex_doc/formatters/html/dist/*.js")), 0, "")

config :ex_doc_simple_markdown, [
    rules: fn rules ->
        :ok = SimpleMarkdownExtensionHighlightJS.setup
        SimpleMarkdownExtensionBlueprint.add_rule(rules)
    end
]

config :ex_doc, :markdown_processor, ExDocSimpleMarkdown

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
