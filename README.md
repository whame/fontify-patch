fontify-patch
=============

fontify-patch is an Emacs package for fontifying buffers (or strings) that
contain patch diffs. For example, mail buffers containing patches:

![screenshot](https://github.com/whame/fontify-patch/assets/9569246/8814468f-199e-4344-a895-949c0f02ba3c)

## Getting started

fontify-patch can be used for any suitable mode. To fontify a buffer, just call
`fontify-patch-buffer` (to fontify just a string, use `fontify-patch-text`).

For example, to fontify mail containing patches with the email client `mu4e`
(which uses `gnus` to display messages), call `fontify-patch-buffer` in the
display hook:

```elisp
(add-hook 'gnus-part-display-hook 'fontify-patch-buffer)
```

A complete example configuration could look like this:

```elisp
(use-package fontify-patch
  :after mu4e
  :load-path "/path/to/fontify-patch" ;; Until availabe in MELPA.
  :config
  (add-hook 'gnus-part-display-hook 'fontify-patch-buffer))
```
