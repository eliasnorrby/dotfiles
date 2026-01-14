export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`opencode_notification done`
      }

      if (event.type === "session.error") {
        await $`opencode_notification error`
      }
    },
  }
}
