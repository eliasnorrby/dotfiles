return {
  init_options = {
    -- Find-references in the work monorepo loads all referenced projects,
    -- peaking >5GB; node's default ~4GB heap limit kills tsserver.
    maxTsServerMemory = 12288,
  },
}
