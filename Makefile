# Makefile for share/public-keys
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HEREIAM     = $(shell pwd)
REMOTEHOST  = 192.0.2.1
HOMEDOTSSH := ~/.ssh
SSHPUBKEYS := authorized_keys
SSHKEYLIST := ssh.ak-iphone6-rsa.pub \
			  ssh.ak-macbookair2011-rsa.pub \
			  ssh.cr-iphone6-rsa.pub \
			  ssh.cr-macbookair2011-rsa.pub \
			  ssh.cr-rokkaku-rsa.pub

.PHONY: clean
here:
	@echo $(HEREIAM)

ssh-authorized-keys: $(SSHKEYLIST)
	if [ -s "./$@" ]; then \
		for v in $(SSHKEYLIST); do \
			grep `awk '{ print $$2 }' $$v` $@ || cat $$v >> $@ ;\
		done ;\
	else \
		cat $(SSHKEYLIST) > $@ ;\
	fi

update-ssh-public-keys:
	for v in $(SSHKEYLIST); do \
		diff -u $(HOMEDOTSSH)/$$v ./$$v || cp -vp $(HOMEDOTSSH)/$$v ./ ;\
	done

deploy-ssh-public-key:
	cat ssh-authorized-keys | \
		ssh $(REMOTEHOST) "cat > $(HOMEDOTSSH)/$(SSHPUBKEYS) && chmod 600 $(HOMEDOTSSH)/$(SSHPUBKEYS)"

pgp-key-list:
	gpg --list-keys

push:
	for G in `git remote show -n`; do \
		git push --tags $$G master; \
	done

distclean:
	rm -f ./ssh-authorized-keys

