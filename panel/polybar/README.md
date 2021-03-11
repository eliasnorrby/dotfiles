# Polybar

The curor changed to an unthemed (default X?) version when hovering over polybar. I had to follow [this][1] example to theme it. But I don't know enough about GTK to add it to provisioning.

```diff
# /usr/share/icons/default/index.theme
  [icon theme]
- Inherits=xcursor-breeze
+ Inherits=breeze_cursors
```

[1]: https://www.reddit.com/r/Polybar/comments/fv1c2f/polybar_using_default_x_cursor/?utm_source=share&utm_medium=web2x&context=3
