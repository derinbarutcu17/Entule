.PHONY: build release release-zip install run clean

APP_NAME = Entule
DIST_DIR = dist
APP_BUNDLE = $(DIST_DIR)/$(APP_NAME).app
DMG_PATH = $(DIST_DIR)/$(APP_NAME).dmg
ZIP_PATH = $(DIST_DIR)/$(APP_NAME).app.zip

build:
	@echo "Building $(APP_NAME)..."
	@swift build
	@BIN_PATH=$$(swift build --show-bin-path); \
	mkdir -p $(APP_BUNDLE)/Contents/MacOS; \
	mkdir -p $(APP_BUNDLE)/Contents/Resources; \
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist; \
	cp $$BIN_PATH/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME); \
	if [ -d Resources ]; then cp -R Resources/. $(APP_BUNDLE)/Contents/Resources/; fi; \
	chmod +x $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME); \
	printf 'APPL????' > $(APP_BUNDLE)/Contents/PkgInfo; \
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "Built at $(APP_BUNDLE)"

run: build
	@echo "Running $(APP_NAME)..."
	@open $(APP_BUNDLE)

install: build
	@echo "Installing to /Applications..."
	@pkill -x $(APP_NAME) 2>/dev/null || true
	@rm -rf /Applications/$(APP_NAME).app
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "Installed at /Applications/$(APP_NAME).app"

release:
	@echo "Creating DMG..."
	@rm -rf $(DIST_DIR)/dmg-stage
	@mkdir -p $(DIST_DIR)/dmg-stage
	@$(MAKE) build
	@ditto $(APP_BUNDLE) $(DIST_DIR)/dmg-stage/$(APP_NAME).app
	@ln -s /Applications $(DIST_DIR)/dmg-stage/Applications
	@rm -f $(DIST_DIR)/$(APP_NAME)-temp.dmg
	@hdiutil create -volname "$(APP_NAME)" -srcfolder "$(DIST_DIR)/dmg-stage" -ov -format UDRW "$(DIST_DIR)/$(APP_NAME)-temp.dmg"
	@DEVICE=$$(hdiutil attach -readwrite -noverify -noautoopen "$(DIST_DIR)/$(APP_NAME)-temp.dmg" | awk '/^\/dev\// {print $$1; exit}'); \
	sync; \
	if [ -n "$$DEVICE" ]; then hdiutil detach "$$DEVICE" -force; fi
	@rm -f $(DMG_PATH)
	@hdiutil convert "$(DIST_DIR)/$(APP_NAME)-temp.dmg" -format UDZO -imagekey zlib-level=9 -o $(DMG_PATH)
	@rm -rf $(DIST_DIR)/dmg-stage
	@rm -f $(DIST_DIR)/$(APP_NAME)-temp.dmg
	@echo "DMG created at $(DMG_PATH)"

release-zip:
	@echo "Creating ZIP..."
	@$(MAKE) build
	@rm -f $(ZIP_PATH)
	@ditto -c -k --sequesterRsrc --keepParent $(APP_BUNDLE) $(ZIP_PATH)
	@echo "ZIP created at $(ZIP_PATH)"

clean:
	@rm -rf .build
	@rm -rf $(DIST_DIR)
