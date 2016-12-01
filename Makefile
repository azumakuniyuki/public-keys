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
SSHPUBKEYS := SSH-PUBLIC-KEYS
SSHKEYLIST := ssh.ak-iphone6-rsa.pub \
			  ssh.ak-macbookair2011-rsa.pub \
			  ssh.cr-iphone6-rsa.pub \
			  ssh.cr-macbookair2011-rsa.pub \
			  ssh.cr-rokkaku-rsa.pub

.DEFAULT_GOAL = git-status
REPOS_TARGETS = git-status git-push git-commit-amend git-tag-list git-diff \
				git-reset-soft git-rm-cached git-branch

.PHONY: clean
here:
	@echo $(HEREIAM)

ssh-public-keyring: $(SSHKEYLIST)
	if [ -s "./$(SSHPUBKEYS)" ]; then \
		for v in $(SSHKEYLIST); do \
			grep `awk '{ print $$2 }' $$v` $(SSHPUBKEYS) || cat $$v >> $(SSHPUBKEYS) ;\
		done ;\
	else \
		cat $(SSHKEYLIST) > $(SSHPUBKEYS) ;\
	fi

diff-ssh-public-keys:
	@diff -q $(HOMEDOTSSH) ./ | grep -E 'ssh[.]' | grep -E '[.]pub'

update-ssh-public-keys:
	for v in $(SSHKEYLIST); do \
		diff -u $(HOMEDOTSSH)/$$v ./$$v || cp -vp $(HOMEDOTSSH)/$$v ./ ;\
	done

deploy-ssh-public-key:
	cat $(SSHPUBKEYS) | \
		ssh $(REMOTEHOST) "cat > $(HOMEDOTSSH)/authorized_keys && chmod 600 $(HOMEDOTSSH)/authorized_keys"

pgp-key-list:
	gpg --list-keys

diff push branch:
	@$(MAKE) git-$@
fix-commit-message: git-commit-amend
cancel-the-latest-commit: git-reset-soft
remove-added-file: git-rm-cached

git-status:
	git status

git-push:
	@ for v in `git remote show | grep -v origin`; do \
		printf "[%s]\n" $$v; \
		git push --tags $$v `$(MAKE) git-current-branch`; \
	done

git-tag-list:
	git tag -l

git-diff:
	git diff -w

git-branch:
	git branch -a

git-commit-amend:
	git commit --amend

git-current-branch:
	@git branch --contains=HEAD | grep '*' | awk '{ print $$2 }'


distclean:
	rm -f ./$(SSHPUBKEYS)

