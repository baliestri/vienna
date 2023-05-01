# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

# Annexes
zi light-mode for z-shell/z-a-meta-plugins \
  @annexes+ @console-tools @z-shell @zsh-users+fast

# Oh-My-ZSH
zi wait lucid for \
  OMZL::git.zsh OMZL::functions.zsh \
  OMZL::clipboard.zsh OMZL::termsupport.zsh \
  OMZL::directories.zsh OMZL::directories.zsh \
  OMZL::completion.zsh

zi wait lucid for \
  OMZP::common-aliases OMZP::sudo \
  OMZP::ubuntu OMZP::suse \
  OMZP::systemd OMZP::aliases \
  OMZP::brew OMZP::yarn \
  OMZP::composer OMZP::asdf \
  atload"unalias grv g" OMZP::git

# Community plugins
zi wait lucid for \
  nekofar/zsh-git-flow-avh alexdesousa/hab \
  birdhackor/zsh-exa-ls-plugin \
  djui/alias-tips \
  pick"autopair.zsh" hlissner/zsh-autopair

zi wait lucid for \
  z-shell/zsh-fancy-completions

zi wait'1' pack atload=+"zicompinit_fast; zicdreplay" for \
  system-completions

zi lucid wait'(( $+commands[brew] ))' pack atload=+"zicompinit_fast; zicdreplay" for \
  brew-completions

# Self plugins/snippets
zi ice lucid wait'(( $+commands[pnpm] ))' blockf atpull'zi creinstall -q .'
zi light baliestri/pnpm.plugin.zsh

zi light baliestri/laravel.plugin.zsh
zi light baliestri/adonisjs.plugin.zsh

zi light baliestri/git-profiles.plugin.zsh

# Theming
zi ice as"command" from"gh-r" \
  atclone"./starship init zsh > starship.zsh" \
  atclone"./starship completions zsh > _starship" \
  atpull"%atclone" src"starship.zsh"
zi light starship/starship
