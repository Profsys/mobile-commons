FILES=scripts/profsys-graddle.bash
INSTALL_DIR=/usr/local/bin

install:
	chmod +x $(FILES)
	cp $(FILES) $(INSTALL_DIR)/
uninstall:
	echo "Remove ${FILES} in $(INSTALL_DIR)"
