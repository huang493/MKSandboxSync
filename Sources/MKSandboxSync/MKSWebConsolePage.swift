import Foundation

enum MKSWebConsolePage {
    static let html = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MKSandboxSync Console</title>
  <style>
    :root {
      --bg: #f6f7f9;
      --panel: #ffffff;
      --line: #d9dde5;
      --text: #17202a;
      --muted: #677281;
      --accent: #1769aa;
      --danger: #b3261e;
      --warn: #8a5a00;
      --ok: #176a3a;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font: 14px/1.45 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color: var(--text);
      background: var(--bg);
    }
    header {
      height: 56px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 20px;
      border-bottom: 1px solid var(--line);
      background: var(--panel);
    }
    header strong { font-size: 17px; }
    header span { color: var(--muted); font-size: 12px; }
    main {
      display: grid;
      grid-template-columns: 280px minmax(320px, 1fr);
      min-height: calc(100vh - 56px);
    }
    aside {
      border-right: 1px solid var(--line);
      background: var(--panel);
      padding: 14px;
      overflow: auto;
    }
    section {
      padding: 18px;
      min-width: 0;
    }
    .toolbar {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-wrap: wrap;
      margin-bottom: 12px;
    }
    button, input {
      font: inherit;
    }
    button {
      min-height: 32px;
      padding: 6px 10px;
      border: 1px solid var(--line);
      background: #fff;
      color: var(--text);
      cursor: pointer;
      border-radius: 6px;
    }
    button:hover { border-color: #aab3c0; }
    button.primary {
      color: #fff;
      background: var(--accent);
      border-color: var(--accent);
    }
    button.danger {
      color: #fff;
      background: var(--danger);
      border-color: var(--danger);
    }
    button:disabled {
      opacity: .45;
      cursor: not-allowed;
    }
    input {
      min-height: 32px;
      padding: 6px 8px;
      border: 1px solid var(--line);
      border-radius: 6px;
      min-width: 260px;
    }
    .tree button {
      width: 100%;
      text-align: left;
      margin: 3px 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .tree button.active {
      border-color: var(--accent);
      color: var(--accent);
      background: #eef6fc;
    }
    .path {
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
      color: var(--muted);
      overflow-wrap: anywhere;
    }
    .grid {
      border: 1px solid var(--line);
      background: var(--panel);
      border-radius: 8px;
      overflow: hidden;
    }
    .row {
      display: grid;
      grid-template-columns: 1fr 96px 160px 88px;
      gap: 10px;
      align-items: center;
      padding: 9px 12px;
      border-bottom: 1px solid var(--line);
    }
    .row:last-child { border-bottom: 0; }
    .row.header {
      font-size: 12px;
      color: var(--muted);
      background: #fbfcfd;
      font-weight: 600;
    }
    .name {
      border: 0;
      padding: 0;
      background: transparent;
      text-align: left;
      color: var(--accent);
      min-height: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .muted { color: var(--muted); }
    textarea {
      width: 100%;
      min-height: 360px;
      resize: vertical;
      padding: 12px;
      border: 1px solid var(--line);
      border-radius: 8px;
      font: 13px/1.45 ui-monospace, SFMono-Regular, Menlo, monospace;
      background: #fff;
    }
    .dropzone {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 58px;
      margin-bottom: 12px;
      padding: 12px;
      border: 1px dashed #9aa7b8;
      border-radius: 8px;
      color: var(--muted);
      background: #fbfcfd;
      text-align: center;
    }
    .dropzone.active {
      border-color: var(--accent);
      color: var(--accent);
      background: #eef6fc;
    }
    .editor {
      margin-top: 14px;
    }
    .preview {
      display: none;
      margin-bottom: 12px;
      padding: 12px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: #fff;
      overflow: auto;
    }
    .preview.show { display: block; }
    .preview img {
      display: block;
      max-width: 100%;
      max-height: 420px;
      object-fit: contain;
    }
    .plist-table {
      width: 100%;
      border-collapse: collapse;
      font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
      font-size: 12px;
    }
    .plist-table td {
      border-bottom: 1px solid var(--line);
      padding: 6px 8px;
      vertical-align: top;
    }
    .plist-key { color: var(--accent); white-space: nowrap; }
    .plist-type { color: var(--muted); width: 96px; }
    .notice {
      display: none;
      margin: 12px 0;
      padding: 10px 12px;
      border-radius: 8px;
      border: 1px solid var(--line);
      background: #fff;
    }
    .notice.show { display: block; }
    .notice.warn { border-color: #e0b85a; background: #fff8e8; color: var(--warn); }
    .notice.ok { border-color: #78bf8c; background: #effaf2; color: var(--ok); }
    .notice.error { border-color: #d98b86; background: #fff0ef; color: var(--danger); }
    .confirm {
      display: none;
      gap: 8px;
      align-items: center;
      margin: 12px 0;
      padding: 10px;
      border: 1px solid #e0b85a;
      background: #fff8e8;
      border-radius: 8px;
    }
    .confirm.show { display: flex; }
    .spacer { flex: 1; }
    @media (max-width: 760px) {
      main { grid-template-columns: 1fr; }
      aside { border-right: 0; border-bottom: 1px solid var(--line); }
      .row { grid-template-columns: 1fr; }
      input { min-width: 0; width: 100%; }
    }
  </style>
</head>
<body>
  <header>
    <div>
      <strong>MKSandboxSync Console</strong>
      <span id="appInfo"></span>
    </div>
    <button id="reloadManifest">Reload</button>
  </header>
  <main>
    <aside>
      <div class="toolbar">
        <button class="primary" id="rootsButton">Roots</button>
        <button id="defaultsButton">Defaults</button>
        <button id="logsButton">Logs</button>
      </div>
      <div class="path" id="currentPath">Loading manifest...</div>
      <div class="tree" id="roots"></div>
    </aside>
    <section>
      <div class="toolbar">
        <button id="upButton" title="Parent directory">&lt;</button>
        <button id="refreshButton">Refresh</button>
        <input id="newFilePath" placeholder="/Documents/new-file.txt">
        <button id="createFileButton">Create file</button>
        <input id="newFolderPath" placeholder="Folder name">
        <button id="createFolderButton">Create folder</button>
      </div>
      <div id="dropzone" class="dropzone">Drop files or folders here to upload into the current directory. Click Confirm to sync.</div>
      <div id="message" class="notice"></div>
      <div id="confirm" class="confirm">
        <span id="confirmText"></span>
        <span class="spacer"></span>
        <button id="cancelConfirm">Cancel</button>
        <button class="danger" id="runConfirm">Confirm</button>
      </div>
      <div class="grid" id="listing"></div>
      <div class="editor">
        <div class="toolbar">
          <strong id="editorTitle">No file selected</strong>
          <span class="spacer"></span>
          <button id="formatJSONButton" disabled>Format JSON</button>
          <button class="primary" id="saveButton" disabled>Save</button>
          <button class="danger" id="deleteButton" disabled>Delete</button>
        </div>
        <div id="preview" class="preview"></div>
        <textarea id="editor" disabled placeholder="Select a text-like file to read or edit. Binary files may not display correctly."></textarea>
      </div>
    </section>
  </main>
  <script>
    const state = {
      manifest: null,
      currentPath: "/",
      selectedFile: null,
      selectedKind: null,
      pendingAction: null
    };

    const $ = (id) => document.getElementById(id);
    const api = (path) => path;

    function showMessage(text, kind = "ok") {
      const node = $("message");
      node.textContent = text;
      node.className = "notice show " + kind;
      window.clearTimeout(showMessage.timer);
      showMessage.timer = window.setTimeout(() => {
        node.className = "notice";
      }, 4200);
    }

    async function requestJSON(url, options) {
      const response = await fetch(url, options);
      const text = await response.text();
      if (!response.ok) {
        throw new Error(text || response.statusText);
      }
      return text ? JSON.parse(text) : {};
    }

    async function requestText(url, options) {
      const response = await fetch(url, options);
      const text = await response.text();
      if (!response.ok) {
        throw new Error(text || response.statusText);
      }
      return text;
    }

    function formatBytes(size) {
      if (!Number.isFinite(size)) return "";
      if (size < 1024) return size + " B";
      if (size < 1024 * 1024) return (size / 1024).toFixed(1) + " KB";
      return (size / 1024 / 1024).toFixed(1) + " MB";
    }

    function fileExtension(path) {
      const name = path.split("/").pop() || "";
      const index = name.lastIndexOf(".");
      return index >= 0 ? name.slice(index + 1).toLowerCase() : "";
    }

    function isImagePath(path) {
      return ["png", "jpg", "jpeg", "gif", "webp", "bmp", "heic", "heif"].includes(fileExtension(path));
    }

    function isPlistPath(path) {
      return fileExtension(path) === "plist";
    }

    function resolveInputPath(value) {
      const trimmed = value.trim();
      if (!trimmed) return "";
      if (trimmed.startsWith("/")) return trimmed;
      const base = state.currentPath && state.currentPath.startsWith("/") ? state.currentPath : "/";
      let relative = trimmed;
      while (relative.startsWith("/")) {
        relative = relative.slice(1);
      }
      return (base === "/" ? "" : base) + "/" + relative;
    }

    function resetPreview() {
      const preview = $("preview");
      preview.className = "preview";
      preview.innerHTML = "";
    }

    function renderImagePreview(blob, path) {
      const preview = $("preview");
      const image = document.createElement("img");
      image.alt = path;
      image.src = URL.createObjectURL(blob);
      image.onload = () => URL.revokeObjectURL(image.src);
      preview.innerHTML = "";
      preview.appendChild(image);
      preview.className = "preview show";
    }

    function renderPlistPreview(text) {
      const preview = $("preview");
      try {
        const value = typeof text === "string" ? JSON.parse(text) : text;
        const rows = [];
        walkJSONValue(value, "", rows);
        const table = document.createElement("table");
        table.className = "plist-table";
        table.innerHTML = "<tbody>" + rows.map(row => (
          "<tr><td class='plist-key'>" + escapeHTML(row.path || "(root)") +
          "</td><td class='plist-type'>" + escapeHTML(row.type) +
          "</td><td>" + escapeHTML(row.value) + "</td></tr>"
        )).join("") + "</tbody>";
        preview.innerHTML = "";
        preview.appendChild(table);
        preview.className = "preview show";
      } catch (error) {
        preview.textContent = "Unable to preview plist: " + error.message;
        preview.className = "preview show";
      }
    }

    function walkJSONValue(value, path, rows) {
      if (Array.isArray(value)) {
        rows.push({ path, type: "array", value: value.length + " items" });
        value.forEach((child, index) => walkJSONValue(child, path + "[" + index + "]", rows));
        return;
      }
      if (value && typeof value === "object") {
        const keys = Object.keys(value);
        rows.push({ path, type: "dict", value: keys.length + " keys" });
        keys.forEach(key => walkJSONValue(value[key], path ? path + "." + key : key, rows));
        return;
      }
      rows.push({ path, type: value === null ? "null" : typeof value, value: String(value) });
    }

    function escapeHTML(value) {
      return String(value).replace(/[&<>"']/g, char => {
        if (char === "&") return "&amp;";
        if (char === "<") return "&lt;";
        if (char === ">") return "&gt;";
        if (char.charCodeAt(0) === 34) return "&quot;";
        return "&#039;";
      });
    }

    function setConfirm(text, action) {
      state.pendingAction = action;
      $("confirmText").textContent = text;
      $("confirm").classList.add("show");
    }

    function clearConfirm() {
      state.pendingAction = null;
      $("confirm").classList.remove("show");
    }

    async function loadManifest() {
      clearConfirm();
      state.manifest = await requestJSON(api("/mkss/manifest"));
      $("appInfo").textContent = " - " + state.manifest.appName + " (" + state.manifest.bundleIdentifier + ")";
      renderRoots();
      if (state.manifest.roots.length > 0) {
        await openDirectory(state.manifest.roots[0].path);
      }
    }

    function renderRoots() {
      const roots = $("roots");
      roots.innerHTML = "";
      for (const root of state.manifest.roots) {
        const button = document.createElement("button");
        button.textContent = root.path;
        button.className = state.currentPath === root.path ? "active" : "";
        button.onclick = () => openDirectory(root.path);
        roots.appendChild(button);
      }
    }

    async function openDirectory(path) {
      clearConfirm();
      state.currentPath = path;
      state.selectedFile = null;
      state.selectedKind = null;
      $("currentPath").textContent = path;
      $("editorTitle").textContent = "No file selected";
      $("editor").value = "";
      $("editor").disabled = true;
      $("formatJSONButton").disabled = true;
      $("saveButton").disabled = true;
      $("deleteButton").disabled = true;
      resetPreview();
      renderRoots();

      const listing = await requestJSON(api("/mkss/files?path=" + encodeURIComponent(path)));
      renderListing(listing.entries || []);
    }

    function renderListing(entries) {
      const listing = $("listing");
      listing.innerHTML = "";

      const header = document.createElement("div");
      header.className = "row header";
      header.innerHTML = "<div>Name</div><div>Size</div><div>Modified</div><div>Action</div>";
      listing.appendChild(header);

      if (!entries.length) {
        const empty = document.createElement("div");
        empty.className = "row";
        empty.innerHTML = "<div class='muted'>Empty directory</div><div></div><div></div><div></div>";
        listing.appendChild(empty);
        return;
      }

      for (const entry of entries) {
        const row = document.createElement("div");
        row.className = "row";

        const name = document.createElement("button");
        name.className = "name";
        name.textContent = (entry.isDirectory ? "[dir] " : "[file] ") + entry.name;
        name.title = entry.path;
        name.onclick = () => entry.isDirectory ? openDirectory(entry.path) : openFile(entry.path);

        const action = document.createElement("button");
        action.textContent = "Delete";
        action.onclick = () => confirmDelete(entry.path, entry.isDirectory);

        row.appendChild(name);
        row.appendChild(textCell(entry.isDirectory ? "" : formatBytes(entry.size)));
        row.appendChild(textCell(entry.modifiedAt ? new Date(entry.modifiedAt).toLocaleString() : ""));
        row.appendChild(action);
        listing.appendChild(row);
      }
    }

    function textCell(text) {
      const div = document.createElement("div");
      div.textContent = text;
      return div;
    }

    async function openFile(path) {
      clearConfirm();
      state.selectedFile = path;
      state.selectedKind = isImagePath(path) ? "image" : (isPlistPath(path) ? "plist" : "text");
      $("editorTitle").textContent = path;
      resetPreview();
      $("deleteButton").disabled = false;
      if (state.selectedKind === "image") {
        const response = await fetch(api("/mkss/file?path=" + encodeURIComponent(path)));
        if (!response.ok) throw new Error(await response.text());
        const blob = await response.blob();
        renderImagePreview(blob, path);
        $("editor").value = "";
        $("editor").disabled = true;
        $("formatJSONButton").disabled = true;
        $("saveButton").disabled = true;
        return;
      }

      $("editor").disabled = false;
      $("formatJSONButton").disabled = false;
      $("saveButton").disabled = false;
      if (state.selectedKind === "plist") {
        const payload = await requestJSON(api("/mkss/plist?path=" + encodeURIComponent(path)));
        $("editor").value = JSON.stringify(payload.value, null, 2);
        renderPlistPreview(payload.value);
        showMessage("Loaded plist (" + payload.format + ") as editable JSON.");
        return;
      }
      $("editor").value = await requestText(api("/mkss/file?path=" + encodeURIComponent(path)));
    }

    function confirmSave() {
      if (!state.selectedFile) return;
      const path = state.selectedFile;
      const content = $("editor").value;
      setConfirm("Confirm saving changes to " + path + "?", async () => {
        let endpoint = api("/mkss/file?path=" + encodeURIComponent(path));
        let body = content;
        if (state.selectedKind === "plist") {
          const parsed = JSON.parse(content);
          body = JSON.stringify(parsed);
          endpoint = api("/mkss/plist?path=" + encodeURIComponent(path));
        }
        await fetch(endpoint, {
          method: "PUT",
          body
        }).then(async (response) => {
          if (!response.ok) throw new Error(await response.text());
        });
        showMessage("Saved " + path);
        if (state.selectedKind === "plist") {
          renderPlistPreview(JSON.parse(content));
        }
        await openDirectory(parentPath(path));
        await openFile(path);
      });
    }

    function confirmDelete(path, isDirectory) {
      setConfirm("Confirm deleting " + path + "?", async () => {
        await fetch(api("/mkss/file?path=" + encodeURIComponent(path)), { method: "DELETE" })
          .then(async (response) => {
            if (!response.ok) throw new Error(await response.text());
          });
        showMessage("Deleted " + path);
        if (state.selectedFile === path) {
          state.selectedFile = null;
          state.selectedKind = null;
          $("editor").value = "";
          $("editor").disabled = true;
          $("formatJSONButton").disabled = true;
          $("saveButton").disabled = true;
          $("deleteButton").disabled = true;
          $("editorTitle").textContent = "No file selected";
          resetPreview();
        }
        await openDirectory(isDirectory ? parentPath(path) : state.currentPath);
      });
    }

    function confirmCreateFile() {
      const path = resolveInputPath($("newFilePath").value);
      if (!path) {
        showMessage("Enter a file path first.", "warn");
        return;
      }
      setConfirm("Confirm creating or overwriting " + path + "?", async () => {
        await fetch(api("/mkss/file?path=" + encodeURIComponent(path)), {
          method: "PUT",
          body: ""
        }).then(async (response) => {
          if (!response.ok) throw new Error(await response.text());
        });
        showMessage("Created " + path);
        await openDirectory(parentPath(path));
        await openFile(path);
      });
    }

    function confirmCreateFolder() {
      const path = resolveInputPath($("newFolderPath").value);
      if (!path) {
        showMessage("Enter a folder path first.", "warn");
        return;
      }
      setConfirm("Confirm creating folder " + path + "?", async () => {
        await fetch(api("/mkss/directory?path=" + encodeURIComponent(path)), {
          method: "POST"
        }).then(async (response) => {
          if (!response.ok) throw new Error(await response.text());
        });
        showMessage("Created folder " + path);
        $("newFolderPath").value = "";
        await openDirectory(parentPath(path));
      });
    }

    async function prepareDroppedItems(event) {
      event.preventDefault();
      $("dropzone").classList.remove("active");

      if (!state.currentPath || !state.currentPath.startsWith("/")) {
        showMessage("Select a directory before dropping files.", "warn");
        return;
      }

      const files = await collectDroppedFiles(event.dataTransfer);
      if (!files.length) {
        showMessage("No files found in dropped items.", "warn");
        return;
      }

      const previewNames = files.slice(0, 5).map(item => item.relativePath).join(", ");
      const more = files.length > 5 ? " and " + (files.length - 5) + " more" : "";
      setConfirm("Confirm uploading " + files.length + " file(s) into " + state.currentPath + ": " + previewNames + more + "?", async () => {
        for (const item of files) {
          const targetPath = joinPath(state.currentPath, item.relativePath);
          await uploadBrowserFile(targetPath, item.file);
        }
        showMessage("Uploaded " + files.length + " file(s).");
        await openDirectory(state.currentPath);
      });
    }

    async function collectDroppedFiles(dataTransfer) {
      const items = Array.from(dataTransfer.items || []);
      if (items.length && items.some(item => item.webkitGetAsEntry)) {
        const collected = [];
        for (const item of items) {
          const entry = item.webkitGetAsEntry && item.webkitGetAsEntry();
          if (entry) {
            const files = await walkEntry(entry, "");
            collected.push(...files);
          }
        }
        return collected;
      }

      return Array.from(dataTransfer.files || []).map(file => ({
        file,
        relativePath: file.name
      }));
    }

    function walkEntry(entry, prefix) {
      return new Promise((resolve, reject) => {
        if (entry.isFile) {
          entry.file(file => resolve([{ file, relativePath: prefix + file.name }]), reject);
          return;
        }

        if (!entry.isDirectory) {
          resolve([]);
          return;
        }

        const reader = entry.createReader();
        const entries = [];
        const readBatch = () => {
          reader.readEntries(async batch => {
            if (!batch.length) {
              try {
                const nested = await Promise.all(entries.map(child => walkEntry(child, prefix + entry.name + "/")));
                resolve(nested.flat());
              } catch (error) {
                reject(error);
              }
              return;
            }
            entries.push(...batch);
            readBatch();
          }, reject);
        };
        readBatch();
      });
    }

    async function uploadBrowserFile(path, file) {
      const data = await file.arrayBuffer();
      await fetch(api("/mkss/file?path=" + encodeURIComponent(path)), {
        method: "PUT",
        body: data
      }).then(async response => {
        if (!response.ok) throw new Error(await response.text());
      });
    }

    function joinPath(base, relative) {
      const cleanBase = base.endsWith("/") ? base.slice(0, -1) : base;
      const cleanRelative = relative.split("/").filter(Boolean).join("/");
      return cleanBase + "/" + cleanRelative;
    }

    function parentPath(path) {
      const parts = path.split("/").filter(Boolean);
      if (parts.length <= 1) return "/" + (parts[0] || "");
      parts.pop();
      return "/" + parts.join("/");
    }

    async function showDefaults() {
      clearConfirm();
      state.currentPath = "(UserDefaults)";
      $("currentPath").textContent = "UserDefaults";
      $("listing").innerHTML = "";
      $("editorTitle").textContent = "UserDefaults snapshot";
      $("editor").disabled = false;
      $("formatJSONButton").disabled = false;
      $("saveButton").disabled = true;
      $("deleteButton").disabled = true;
      resetPreview();
      const data = await requestJSON(api("/mkss/defaults"));
      $("editor").value = JSON.stringify(data, null, 2);
      showMessage("UserDefaults editing is available through API; this page currently shows a read-only snapshot.");
    }

    async function showLogs() {
      clearConfirm();
      state.currentPath = "(Logs)";
      $("currentPath").textContent = "Logs";
      $("listing").innerHTML = "";
      $("editorTitle").textContent = "Logs";
      $("editor").disabled = false;
      $("formatJSONButton").disabled = false;
      $("saveButton").disabled = true;
      $("deleteButton").disabled = true;
      resetPreview();
      const data = await requestJSON(api("/mkss/logs"));
      $("editor").value = JSON.stringify(data, null, 2);
    }

    $("reloadManifest").onclick = () => loadManifest().catch(handleError);
    $("rootsButton").onclick = () => loadManifest().catch(handleError);
    $("defaultsButton").onclick = () => showDefaults().catch(handleError);
    $("logsButton").onclick = () => showLogs().catch(handleError);
    $("refreshButton").onclick = () => {
      if (state.currentPath && state.currentPath.startsWith("/")) {
        openDirectory(state.currentPath).catch(handleError);
      }
    };
    $("upButton").onclick = () => {
      if (state.currentPath && state.currentPath.startsWith("/")) {
        openDirectory(parentPath(state.currentPath)).catch(handleError);
      }
    };
    $("saveButton").onclick = confirmSave;
    $("formatJSONButton").onclick = () => {
      try {
        const parsed = JSON.parse($("editor").value);
        $("editor").value = JSON.stringify(parsed, null, 2);
        showMessage("JSON formatted.");
      } catch (error) {
        showMessage("Invalid JSON: " + error.message, "error");
      }
    };
    $("deleteButton").onclick = () => {
      if (state.selectedFile) confirmDelete(state.selectedFile, false);
    };
    $("createFileButton").onclick = confirmCreateFile;
    $("createFolderButton").onclick = confirmCreateFolder;
    $("dropzone").ondragover = event => {
      event.preventDefault();
      $("dropzone").classList.add("active");
    };
    $("dropzone").ondragleave = () => $("dropzone").classList.remove("active");
    $("dropzone").ondrop = event => prepareDroppedItems(event).catch(handleError);
    $("cancelConfirm").onclick = clearConfirm;
    $("runConfirm").onclick = async () => {
      if (!state.pendingAction) return;
      const action = state.pendingAction;
      clearConfirm();
      try {
        await action();
      } catch (error) {
        handleError(error);
      }
    };

    function handleError(error) {
      showMessage(error.message || String(error), "error");
    }

    loadManifest().catch(handleError);
  </script>
</body>
</html>
"""
}
