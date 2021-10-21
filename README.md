# Not maintained anymore

There are issues with this plugin, but I've decided that I'm not going to try to maintain it.  
I also converted my nvim config to lua and am trying to use only lua based plugins.

A good lua based plugin that solves this same problem, and even better: [stabilize.nvim](https://github.com/luukvbaal/stabilize.nvim)


# stable-windows

Keeps vim windows stable when layout changes.

It really annoys me when opening new windows in vim (especially
using the quickfix or location list) and vim automatically
adjusts the text in all the windows so the cursor line is 
centered.

This is what I'm talking about:  
![Unstable vim windows](https://github.com/gillyb/assets/raw/master/stable-windows/not-stable.gif)

And after using the 'stable-windows' plugin, your vim will
behave like this:
![Stable vim windows](https://github.com/gillyb/assets/raw/master/stable-windows/stable.gif)

## Installation

* VimPlug  
  Place this in your .vimrc:  
  `Plug gillyb/stable-windows`

  And then open vim and run:  
  ```bash
  :source %
  :PlugInstall
  ```

* Vundle  
  Place this in your .vimrc:  
  `Plugin gillyb/stable-windows`

  And then open vim and run:  
  ```bash
  :source %
  :PlugInstall
  ```

* NeoBundle  
  Place this in your .vimrc:  
  `NeoBundle gillyb/stable-windows`

  And then open vim and run:  
  ```bash
  :source %
  :NeoBundleInstall
  ```

* Pathogen  
  Run the following in a terminal:  
  ```bash
  cd ~/.vim/bundle
  git clone https://github.com/gillyb/stable-windows
  ```


## Usage

You do not need to do anything special (except installing)
to use this plugin. Once it's loaded in vim, it will just
work.

Please enjoy, feel free to contribute and keep on vimming.
