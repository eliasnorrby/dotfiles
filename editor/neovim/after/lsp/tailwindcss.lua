return {
  settings = {
    tailwindCSS = {
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass', 'div*' },
      experimental = {
        classRegex = {
          -- { '\\w+\\.([a-z0-9-]+)', '([a-z0-9-]+)' },
          -- Emmet with a tag (optionally with an #id), then any number of .class tokens
          { '\\w+(?:#[a-z0-9_-]+)?((?:\\.[a-z0-9-:]+)+)', '([a-z0-9-:]+)' },

          -- Emmet starting with a dot (no tag): `.bg-gray-500.fle`
          { '((?:\\.[a-z0-9-:]+)+)', '([a-z0-9-:]+)' },
        },
      },
    },
  },
}
