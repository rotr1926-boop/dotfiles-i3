# Fix: login loop di SDDM (i3 non parte)

**Sintomo**: dopo `pacman -Syu` e riavvio, inserendo la password in SDDM la
sessione si chiude subito e si torna al login. Su tty non succede niente di
visibile; `sddm` logga `Auth: sddm-helper exited with 127`.

## Causa

Una riga in `~/.bashrc`:

    set bell-style none

Purtroppo `set bell-style none` **non è un comando bash**: è una direttiva di
readline che va messa in `~/.inputrc` (lì era già presente, per quello l'ai
trovato due volte). In un prompt interattivo `bell-style` non è interpretato
come comando, quindi non dà errore, ma:

1. `/usr/share/sddm/scripts/Xsession i3` si rilancia come **login shell** bash
   (`exec $SHELL --login ...`), che carica `~/.profile` -> `~/.bash_profile`
   -> `~/.bashrc`.
2. La riga `set bell-style none` viene letta da bash come `set` con argomenti,
   cioè **sovrascrive i parametri posizionali** `$1`/`$2`, che prima erano il
   comando di sessione.
3. In fondo a Xsession c'è `exec $@`, che quindi esegue `exec bell-style none`
   -> `bell-style: not found` -> **exit 127**.
4. SDDM vede la sessione morta e riporta al login. Loop infinito.

La i3 config NON c'entrava nulla: ho verificato che `i3` partiva e restava
su un X virtuale (Xvfb) con lo stesso identico config.

## Riproduzione

    env -i SHELL=/bin/bash HOME=$HOME USER=$USER LOGNAME=$USER \
      DISPLAY=:99 PATH=/usr/local/bin:/usr/bin:/bin \
      /usr/share/sddm/scripts/Xsession i3

Prima della fix: `EXITED code=127` con `exec: bell-style: not found`.
Dopo la fix: i3 resta in esecuzione.

## Fix

Rimosso `set bell-style none` da `~/.bashrc` (era già presente in
`~/.inputrc`, dove ha senso). Il `.bashrc` è una shell script: le impostazioni
di readline appartengono a `.inputrc`, non a una shell script.