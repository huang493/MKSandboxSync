#if DEBUG
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
    .brand {
      margin-left: 10px;
      color: var(--muted);
      font-size: 12px;
      white-space: nowrap;
    }
    main {
      display: grid;
      grid-template-columns: 280px minmax(320px, 1fr);
      min-height: calc(100vh - 56px);
    }
    aside {
      display: flex;
      flex-direction: column;
      border-right: 1px solid var(--line);
      background: var(--panel);
      padding: 14px;
      overflow: hidden;
    }
    section {
      display: flex;
      flex-direction: column;
      padding: 18px;
      min-width: 0;
      min-height: 0;
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
    .tree {
      flex: 1;
      min-height: 0;
      overflow: auto;
      margin-bottom: 12px;
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
    .listing {
      flex: 0 0 220px;
      min-height: 180px;
      overflow: auto;
    }
    .listing.collapsed {
      display: none;
    }
    .row {
      display: grid;
      grid-template-columns: 1fr 96px 160px 168px;
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
      height: 100%;
      min-height: 0;
      flex: 1;
      resize: none;
      padding: 12px 14px;
      border: 0;
      font: 13px/1.45 ui-monospace, SFMono-Regular, Menlo, monospace;
      background: #fff;
      white-space: pre;
      overflow: auto;
      outline: none;
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
      display: flex;
      flex-direction: column;
      flex: 1;
      min-height: 0;
    }
    .editor.fullscreen {
      position: fixed;
      inset: 12px;
      z-index: 50;
      margin-top: 0;
      padding: 16px;
      border: 1px solid var(--line);
      border-radius: 12px;
      background: var(--bg);
      box-shadow: 0 24px 60px rgba(23, 32, 42, 0.18);
    }
    body.editor-fullscreen {
      overflow: hidden;
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
    .preview video, .preview audio {
      display: block;
      width: 100%;
      max-height: 420px;
      border-radius: 6px;
    }
    .preview video {
      background: #000;
    }
    .preview.image-preview,
    .preview.video-preview {
      display: flex;
      gap: 12px;
      align-items: flex-start;
    }
    .preview-image-wrap {
      flex: 1;
      min-width: 0;
    }
    .preview-meta {
      width: 220px;
      flex: 0 0 220px;
      border-left: 1px solid var(--line);
      padding-left: 12px;
      color: var(--muted);
      font-size: 12px;
      line-height: 1.5;
    }
    .preview-meta strong {
      display: block;
      color: var(--text);
      font-size: 13px;
      margin-bottom: 6px;
      word-break: break-word;
    }
    .preview-meta .meta-row {
      margin-top: 6px;
      word-break: break-word;
    }
    .actions {
      display: flex;
      gap: 8px;
      justify-content: flex-start;
      flex-wrap: wrap;
    }
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
    .sidebar-tools {
      margin-top: auto;
      padding-top: 12px;
      border-top: 1px solid var(--line);
    }
    .sidebar-tools .toolbar {
      margin-bottom: 10px;
    }
    .sidebar-tools input {
      min-width: 0;
      width: 100%;
    }
    .sidebar-tools .toolbar.tight {
      margin-bottom: 8px;
    }
    .sidebar-tools .toolbar.tight.actions {
      align-items: stretch;
    }
    .sidebar-tools .toolbar.tight.actions button {
      flex: 0 0 auto;
    }
    .mode-toggle {
      display: inline-flex;
      border: 1px solid var(--line);
      border-radius: 8px;
      overflow: hidden;
      background: #fff;
    }
    .mode-toggle button {
      border: 0;
      border-right: 1px solid var(--line);
      border-radius: 0;
      min-width: 120px;
    }
    .mode-toggle button:last-child {
      border-right: 0;
    }
    .mode-toggle button.active {
      background: #eef6fc;
      color: var(--accent);
      font-weight: 600;
    }
    .editor-meta {
      color: var(--muted);
      font-size: 12px;
    }
    .editor-shell {
      display: flex;
      flex: 1;
      min-height: 360px;
      border: 1px solid var(--line);
      border-radius: 8px;
      overflow: hidden;
      background: #fff;
    }
    .editor-gutter {
      flex: 0 0 56px;
      padding: 12px 8px;
      border-right: 1px solid var(--line);
      background: #f8fafc;
      color: var(--muted);
      font: 12px/1.45 ui-monospace, SFMono-Regular, Menlo, monospace;
      text-align: right;
      overflow: hidden;
      user-select: none;
    }
    .editor-gutter div {
      height: 18.85px;
      white-space: nowrap;
    }
    .json-outline-panel {
      display: none;
      margin-bottom: 12px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: #fff;
      overflow: hidden;
    }
    .json-outline-panel.show {
      display: block;
    }
    .json-outline-header {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      border-bottom: 1px solid var(--line);
      background: #fbfcfd;
    }
    .json-outline {
      max-height: 240px;
      overflow: auto;
      padding: 10px 12px 12px;
      font: 13px/1.5 ui-monospace, SFMono-Regular, Menlo, monospace;
    }
    .json-outline details {
      margin: 4px 0 4px 14px;
    }
    .json-outline details.root {
      margin-left: 0;
    }
    .json-outline summary {
      cursor: pointer;
      color: var(--text);
    }
    .json-outline .node-key {
      color: var(--accent);
    }
    .json-outline .node-meta {
      color: var(--muted);
    }
    .json-outline .node-value {
      color: var(--ok);
      word-break: break-word;
    }
    .json-outline .outline-error {
      color: var(--danger);
      white-space: pre-wrap;
    }
    .json-editor-overlay {
      display: none;
      position: fixed;
      inset: 0;
      z-index: 100;
      background: rgba(23, 32, 42, 0.38);
      padding: 20px;
    }
    .json-editor-overlay.show {
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .json-editor-dialog {
      display: flex;
      flex-direction: column;
      width: min(1100px, 100%);
      height: min(780px, 100%);
      min-height: 420px;
      border: 1px solid var(--line);
      border-radius: 10px;
      background: var(--panel);
      box-shadow: 0 24px 70px rgba(23, 32, 42, 0.24);
      overflow: hidden;
    }
    .json-editor-dialog .toolbar {
      flex: 0 0 auto;
      margin: 0;
      padding: 12px;
      border-bottom: 1px solid var(--line);
      background: #fbfcfd;
    }
    .json-editor-host {
      flex: 1;
      min-height: 0;
    }
    .json-editor-status {
      padding: 10px 12px;
      border-top: 1px solid var(--line);
      color: var(--muted);
      font-size: 12px;
      background: #fbfcfd;
    }
    body.json-editor-modal-open {
      overflow: hidden;
    }
    @media (max-width: 760px) {
      main { grid-template-columns: 1fr; }
      aside { border-right: 0; border-bottom: 1px solid var(--line); }
      .row { grid-template-columns: 1fr; }
      input { min-width: 0; width: 100%; }
      .sidebar-tools { margin-top: 12px; }
      .editor.fullscreen {
        inset: 0;
        border-radius: 0;
      }
      .editor-shell {
        min-height: 300px;
      }
      .editor-gutter {
        flex-basis: 48px;
      }
      .mode-toggle {
        width: 100%;
      }
      .mode-toggle button {
        flex: 1;
        min-width: 0;
      }
      .json-editor-overlay {
        padding: 0;
      }
      .json-editor-dialog {
        width: 100%;
        height: 100%;
        border-radius: 0;
      }
    }
  </style>
</head>
<body>
  <header>
    <div>
      <strong>MKSandboxSync Console</strong>
      <span id="appInfo"></span>
      <span class="brand">by Mike.Huang</span>
    </div>
    <button id="reloadManifest">Reload</button>
  </header>
  <main>
    <aside>
      <div class="toolbar">
        <button class="primary" id="rootsButton">Roots</button>
        <button id="logsButton">Logs</button>
      </div>
      <div class="toolbar" id="shortcutBar"></div>
      <div class="path" id="currentPath">Loading manifest...</div>
      <div class="tree" id="roots"></div>
      <div class="sidebar-tools">
        <input id="uploadFilesInput" type="file" multiple hidden>
        <div class="toolbar tight actions">
          <button id="uploadFilesButton">Upload files</button>
          <input id="newFilePath" placeholder="/Documents/new-file.txt">
          <button id="createFileButton">Upload / Create file</button>
        </div>
        <div class="toolbar tight">
          <input id="newFolderPath" placeholder="Folder name">
          <button id="createFolderButton">Create folder</button>
        </div>
        <div id="dropzone" class="dropzone">Drop files or folders here to upload into the current directory. Click Confirm to sync.</div>
      </div>
    </aside>
    <section>
      <div class="toolbar">
        <button id="upButton" title="Parent directory">&lt;</button>
        <button id="refreshButton">Refresh</button>
        <button id="toggleListingButton">Hide list</button>
      </div>
      <div id="message" class="notice"></div>
      <div id="confirm" class="confirm">
        <span id="confirmText"></span>
        <span class="spacer"></span>
        <button id="cancelConfirm">Cancel</button>
        <button class="danger" id="runConfirm">Confirm</button>
      </div>
      <div class="grid listing" id="listing"></div>
      <div class="editor" id="editorPanel">
        <div class="toolbar">
          <strong id="editorTitle">No file selected</strong>
          <span id="editorMeta" class="editor-meta"></span>
          <span class="spacer"></span>
          <div class="mode-toggle" id="jsonModeToggle">
            <button id="strictModeButton" class="active" disabled>Strict</button>
            <button id="swiftModeButton" disabled>Swift Compatible</button>
          </div>
          <button id="formatJSONButton" disabled>Format JSON</button>
          <button id="jsonEditorButton" disabled>JSON Editor</button>
          <button id="fullscreenButton">Full Screen</button>
          <button class="primary" id="saveButton" disabled>Save</button>
          <button class="danger" id="deleteButton" disabled>Delete</button>
        </div>
        <div id="preview" class="preview"></div>
        <div id="jsonOutlinePanel" class="json-outline-panel">
          <div class="json-outline-header">
            <strong>JSON Outline</strong>
            <span class="editor-meta" id="jsonOutlineMeta"></span>
            <span class="spacer"></span>
            <button id="expandOutlineButton" disabled>Expand all</button>
            <button id="collapseOutlineButton" disabled>Collapse all</button>
          </div>
          <div id="jsonOutline" class="json-outline"></div>
        </div>
        <div id="editorShell" class="editor-shell">
          <div id="editorGutter" class="editor-gutter"></div>
          <textarea id="editor" disabled wrap="off" spellcheck="false" placeholder="Select a text-like file to read or edit. Binary files may not display correctly."></textarea>
        </div>
      </div>
    </section>
  </main>
  <div id="jsonEditorOverlay" class="json-editor-overlay" role="dialog" aria-modal="true" aria-labelledby="jsonEditorTitle">
    <div class="json-editor-dialog">
      <div class="toolbar">
        <strong id="jsonEditorTitle">JSON Editor</strong>
        <span id="jsonEditorMeta" class="editor-meta"></span>
        <span class="spacer"></span>
        <button id="jsonEditorCloseButton">Cancel</button>
        <button class="primary" id="jsonEditorApplyButton">Apply</button>
      </div>
      <div id="jsonEditorHost" class="json-editor-host"></div>
      <div id="jsonEditorStatus" class="json-editor-status">Loading JSON Editor...</div>
    </div>
  </div>
  <script type="module">
    import { createJSONEditor } from "https://cdn.jsdelivr.net/npm/vanilla-jsoneditor/standalone.js";
    window.MKSCreateJSONEditor = createJSONEditor;
    document.dispatchEvent(new Event("mks-json-editor-ready"));
  </script>
  <script>
    const state = {
      manifest: null,
      currentPath: "/",
      selectedFile: null,
      selectedKind: null,
      pendingAction: null,
      previewObjectURL: null,
      listingSortDirection: "desc",
      jsonParseMode: "strict",
      jsonEditorActive: false,
      jsonEditorInstance: null,
      jsonEditorContent: { text: undefined, json: null },
      listingCollapsed: false,
      editorFullscreen: false
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

    function entryTime(entry) {
      return entry.modifiedAt || entry.createdAt || "";
    }

    function entryTimestamp(entry) {
      const value = entryTime(entry);
      const timestamp = value ? Date.parse(value) : NaN;
      return Number.isFinite(timestamp) ? timestamp : 0;
    }

    function sortEntries(entries) {
      const direction = state.listingSortDirection === "asc" ? 1 : -1;
      return [...entries].sort((lhs, rhs) => {
        const timeDiff = entryTimestamp(lhs) - entryTimestamp(rhs);
        if (timeDiff !== 0) return timeDiff * direction;
        if (lhs.isDirectory !== rhs.isDirectory) return lhs.isDirectory ? -1 : 1;
        return lhs.name.localeCompare(rhs.name, undefined, { sensitivity: "base" });
      });
    }

    function isImagePath(path) {
      return ["png", "jpg", "jpeg", "gif", "webp", "bmp", "heic", "heif"].includes(fileExtension(path));
    }

    function isVideoPath(path) {
      return ["mp4", "mov", "m4v", "webm"].includes(fileExtension(path));
    }

    function isJSONPath(path) {
      return ["json", "geojson"].includes(fileExtension(path));
    }

    function isJSONContext(path, kind) {
      return kind === "plist" || isJSONPath(path) || path === "(Logs)";
    }

    function nextNonWhitespace(text, index) {
      for (let i = index; i < text.length; i += 1) {
        if (!/\\s/.test(text[i])) return text[i];
      }
      return "";
    }

    function stripTrailingCommas(text) {
      let result = "";
      let inString = false;
      let escaped = false;
      for (let i = 0; i < text.length; i += 1) {
        const char = text[i];
        if (inString) {
          result += char;
          if (escaped) {
            escaped = false;
          } else if (char.charCodeAt(0) === 92) {
            escaped = true;
          } else if (char.charCodeAt(0) === 34) {
            inString = false;
          }
          continue;
        }
        if (char.charCodeAt(0) === 34) {
          inString = true;
          result += char;
          continue;
        }
        if (char === ",") {
          const next = nextNonWhitespace(text, i + 1);
          if (next === "}" || next === "]") {
            continue;
          }
        }
        result += char;
      }
      return result;
    }

    function parseJSONText(text) {
      const normalized = state.jsonParseMode === "swift" ? stripTrailingCommas(text) : text;
      return JSON.parse(normalized);
    }

    function formatJSONText(text) {
      return JSON.stringify(parseJSONText(text), null, 2);
    }

    function updateJSONModeButtons() {
      $("strictModeButton").classList.toggle("active", state.jsonParseMode === "strict");
      $("swiftModeButton").classList.toggle("active", state.jsonParseMode === "swift");
    }

    function setJSONEditorActive(active) {
      state.jsonEditorActive = active;
      $("formatJSONButton").disabled = !active || $("editor").disabled;
      $("jsonEditorButton").disabled = !active || $("editor").disabled;
      $("strictModeButton").disabled = !active;
      $("swiftModeButton").disabled = !active;
      $("jsonOutlinePanel").classList.toggle("show", active);
      $("jsonOutlineMeta").textContent = active
        ? (state.jsonParseMode === "swift" ? "Swift compatible: allows trailing commas." : "Strict JSON parsing.")
        : "";
      updateJSONModeButtons();
      refreshJSONOutline();
    }

    function editorText() {
      return $("editor").value;
    }

    function setEditorText(text) {
      $("editor").value = text;
      refreshEditorChrome();
    }

    function refreshEditorMeta() {
      const text = editorText();
      const lines = Math.max(1, text.split("\\n").length);
      const characters = text.length;
      $("editorMeta").textContent = lines + " lines · " + characters + " chars";
    }

    function refreshLineNumbers() {
      const lines = Math.max(1, editorText().split("\\n").length);
      $("editorGutter").innerHTML = Array.from({ length: lines }, (_, index) => "<div>" + (index + 1) + "</div>").join("");
      $("editorGutter").scrollTop = $("editor").scrollTop;
    }

    function summarizeJSONNode(value) {
      if (Array.isArray(value)) return "[" + value.length + "]";
      if (value && typeof value === "object") return "{" + Object.keys(value).length + "}";
      return JSON.stringify(value);
    }

    function buildJSONOutlineNode(label, value, depth = 0) {
      if (Array.isArray(value) || (value && typeof value === "object")) {
        const details = document.createElement("details");
        details.className = depth === 0 ? "root" : "";
        details.open = depth < 2;
        const summary = document.createElement("summary");
        const key = document.createElement("span");
        key.className = "node-key";
        key.textContent = label;
        const meta = document.createElement("span");
        meta.className = "node-meta";
        meta.textContent = " " + summarizeJSONNode(value);
        summary.appendChild(key);
        summary.appendChild(meta);
        details.appendChild(summary);
        const entries = Array.isArray(value)
          ? value.map((entry, index) => ["[" + index + "]", entry])
          : Object.entries(value);
        for (const [childLabel, childValue] of entries) {
          details.appendChild(buildJSONOutlineNode(childLabel, childValue, depth + 1));
        }
        return details;
      }
      const row = document.createElement("div");
      const key = document.createElement("span");
      key.className = "node-key";
      key.textContent = label + ": ";
      const valueNode = document.createElement("span");
      valueNode.className = "node-value";
      valueNode.textContent = JSON.stringify(value);
      row.appendChild(key);
      row.appendChild(valueNode);
      return row;
    }

    function refreshJSONOutline() {
      const outline = $("jsonOutline");
      outline.innerHTML = "";
      $("expandOutlineButton").disabled = true;
      $("collapseOutlineButton").disabled = true;
      if (!state.jsonEditorActive || $("editor").disabled) return;
      try {
        const parsed = parseJSONText(editorText());
        outline.appendChild(buildJSONOutlineNode("root", parsed));
        $("jsonOutlineMeta").textContent = state.jsonParseMode === "swift"
          ? "Swift compatible: allows trailing commas."
          : "Strict JSON parsing.";
        $("expandOutlineButton").disabled = false;
        $("collapseOutlineButton").disabled = false;
      } catch (error) {
        const node = document.createElement("div");
        node.className = "outline-error";
        node.textContent = "Preview unavailable: " + error.message;
        outline.appendChild(node);
        $("jsonOutlineMeta").textContent = state.jsonParseMode === "swift"
          ? "Swift compatible: allows trailing commas."
          : "Strict JSON parsing.";
      }
    }

    function setJSONEditorStatus(text, kind = "") {
      const node = $("jsonEditorStatus");
      node.textContent = text;
      node.className = "json-editor-status" + (kind ? " " + kind : "");
    }

    function waitForJSONEditorFactory() {
      if (window.MKSCreateJSONEditor) {
        return Promise.resolve(window.MKSCreateJSONEditor);
      }
      return new Promise((resolve, reject) => {
        const timeout = window.setTimeout(() => {
          reject(new Error("JSON Editor library could not be loaded. Check network access to jsDelivr."));
        }, 12000);
        document.addEventListener("mks-json-editor-ready", () => {
          window.clearTimeout(timeout);
          resolve(window.MKSCreateJSONEditor);
        }, { once: true });
      });
    }

    async function openJSONEditorDialog() {
      if (!state.jsonEditorActive || $("editor").disabled) return;
      let parsed;
      try {
        parsed = parseJSONText(editorText());
      } catch (error) {
        showMessage("Invalid JSON: " + error.message, "error");
        return;
      }

      $("jsonEditorTitle").textContent = state.selectedFile || "JSON Editor";
      $("jsonEditorMeta").textContent = state.jsonParseMode === "swift"
        ? "Loaded with Swift compatible parsing."
        : "Loaded with strict JSON parsing.";
      $("jsonEditorOverlay").classList.add("show");
      document.body.classList.add("json-editor-modal-open");
      setJSONEditorStatus("Loading JSON Editor...");

      try {
        const createJSONEditor = await waitForJSONEditorFactory();
        state.jsonEditorContent = { text: undefined, json: parsed };
        if (!state.jsonEditorInstance) {
          state.jsonEditorInstance = createJSONEditor({
            target: $("jsonEditorHost"),
            props: {
              content: state.jsonEditorContent,
              onChange: (updatedContent) => {
                state.jsonEditorContent = updatedContent;
              }
            }
          });
        } else {
          state.jsonEditorInstance.set(state.jsonEditorContent);
        }
        setJSONEditorStatus("Edit JSON, then click Apply to update the text editor below.");
      } catch (error) {
        closeJSONEditorDialog();
        showMessage(error.message || String(error), "error");
      }
    }

    function jsonEditorContentText() {
      const content = state.jsonEditorInstance ? state.jsonEditorInstance.get() : state.jsonEditorContent;
      if (content && Object.prototype.hasOwnProperty.call(content, "json")) {
        return JSON.stringify(content.json, null, 2);
      }
      if (content && Object.prototype.hasOwnProperty.call(content, "text")) {
        return formatJSONText(content.text || "");
      }
      return "";
    }

    function applyJSONEditorDialog() {
      try {
        setEditorText(jsonEditorContentText());
        closeJSONEditorDialog();
        showMessage("JSON Editor changes applied.");
      } catch (error) {
        setJSONEditorStatus("Invalid JSON: " + (error.message || String(error)));
      }
    }

    function closeJSONEditorDialog() {
      $("jsonEditorOverlay").classList.remove("show");
      document.body.classList.remove("json-editor-modal-open");
    }

    function setOutlineExpanded(expanded) {
      for (const node of $("jsonOutline").querySelectorAll("details")) {
        node.open = expanded;
      }
    }

    function toggleFullscreen() {
      state.editorFullscreen = !state.editorFullscreen;
      $("editorPanel").classList.toggle("fullscreen", state.editorFullscreen);
      document.body.classList.toggle("editor-fullscreen", state.editorFullscreen);
      $("fullscreenButton").textContent = state.editorFullscreen ? "Exit Full Screen" : "Full Screen";
    }

    function toggleListing() {
      state.listingCollapsed = !state.listingCollapsed;
      $("listing").classList.toggle("collapsed", state.listingCollapsed);
      $("toggleListingButton").textContent = state.listingCollapsed ? "Show list" : "Hide list";
    }

    function refreshEditorChrome() {
      refreshLineNumbers();
      refreshEditorMeta();
      refreshJSONOutline();
    }

    function isAudioPath(path) {
      return ["mp3", "m4a", "aac", "wav", "flac", "ogg", "oga"].includes(fileExtension(path));
    }

    function isPlistPath(path) {
      return fileExtension(path) === "plist";
    }

    function formatDuration(duration) {
      if (!Number.isFinite(duration) || duration <= 0) return "加载中...";
      return duration.toFixed(1) + "s";
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
      if (state.previewObjectURL) {
        URL.revokeObjectURL(state.previewObjectURL);
        state.previewObjectURL = null;
      }
      preview.className = "preview";
      preview.innerHTML = "";
    }

    function renderImagePreview(blob, path) {
      const preview = $("preview");
      const objectURL = URL.createObjectURL(blob);
      state.previewObjectURL = objectURL;
      const image = document.createElement("img");
      const wrap = document.createElement("div");
      const meta = document.createElement("div");
      wrap.className = "preview-image-wrap";
      meta.className = "preview-meta";
      image.alt = path;
      image.src = objectURL;
      wrap.appendChild(image);
      preview.innerHTML = "";
      preview.appendChild(wrap);
      preview.appendChild(meta);
      preview.className = "preview image-preview show";

      const updateMeta = (width, height) => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>尺寸: " + (width && height ? (width + " × " + height) : "加载中...") + "</div>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };

      image.onload = () => updateMeta(image.naturalWidth || 0, image.naturalHeight || 0);
      image.onerror = () => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>无法读取图片尺寸</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };
      updateMeta(0, 0);
    }

    function renderVideoPreview(blob, path) {
      const preview = $("preview");
      const objectURL = URL.createObjectURL(blob);
      state.previewObjectURL = objectURL;
      const video = document.createElement("video");
      const wrap = document.createElement("div");
      const meta = document.createElement("div");
      wrap.className = "preview-image-wrap";
      meta.className = "preview-meta";
      video.src = objectURL;
      video.controls = true;
      video.preload = "metadata";
      wrap.appendChild(video);
      preview.innerHTML = "";
      preview.appendChild(wrap);
      preview.appendChild(meta);
      preview.className = "preview video-preview show";

      const updateMeta = (width, height, duration) => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>尺寸: " + (width && height ? (width + " × " + height) : "加载中...") + "</div>",
          "<div class='meta-row'>时长: " + formatDuration(duration) + "</div>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };

      video.onloadedmetadata = () => updateMeta(video.videoWidth || 0, video.videoHeight || 0, video.duration);
      video.onerror = () => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>无法读取视频信息</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };
      updateMeta(0, 0, 0);
    }

    function renderAudioPreview(blob, path) {
      const preview = $("preview");
      const objectURL = URL.createObjectURL(blob);
      state.previewObjectURL = objectURL;
      const audio = document.createElement("audio");
      const wrap = document.createElement("div");
      const meta = document.createElement("div");
      wrap.className = "preview-image-wrap";
      meta.className = "preview-meta";
      audio.src = objectURL;
      audio.controls = true;
      audio.preload = "metadata";
      wrap.appendChild(audio);
      preview.innerHTML = "";
      preview.appendChild(wrap);
      preview.appendChild(meta);
      preview.className = "preview video-preview show";

      const updateMeta = (duration) => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>时长: " + formatDuration(duration) + "</div>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };

      audio.onloadedmetadata = () => updateMeta(audio.duration);
      audio.onerror = () => {
        meta.innerHTML = [
          "<strong>" + escapeHTML(path.split("/").pop() || path) + "</strong>",
          "<div class='meta-row'>文件大小: " + formatBytes(blob.size) + "</div>",
          "<div class='meta-row'>无法读取音频信息</div>",
          "<div class='meta-row'>路径: " + escapeHTML(path) + "</div>"
        ].join("");
      };
      updateMeta(0);
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
      renderShortcutTargets();
      renderRoots();
      if (state.manifest.roots.length > 0) {
        await openDirectory(state.manifest.roots[0].path);
      }
    }

    function renderShortcutTargets() {
      const shortcuts = $("shortcutBar");
      shortcuts.innerHTML = "";
      for (const shortcut of state.manifest.shortcuts || []) {
        const button = document.createElement("button");
        button.textContent = shortcut.name;
        button.onclick = () => openSpecialTarget(shortcut);
        shortcuts.appendChild(button);
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
      setEditorText("");
      $("editor").disabled = true;
      $("saveButton").disabled = true;
      $("deleteButton").disabled = true;
      setJSONEditorActive(false);
      resetPreview();
      renderRoots();

      const listing = await requestJSON(api("/mkss/files?path=" + encodeURIComponent(path)));
      renderListing(listing.entries || []);
    }

    function renderListing(entries) {
      const listing = $("listing");
      listing.innerHTML = "";
      const sortedEntries = sortEntries(entries);

      const header = document.createElement("div");
      header.className = "row header";
      const modifiedButton = document.createElement("button");
      modifiedButton.className = "name";
      modifiedButton.textContent = "Modified " + (state.listingSortDirection === "desc" ? "↓" : "↑");
      modifiedButton.title = "Toggle modified/created time sorting";
      modifiedButton.onclick = () => {
        state.listingSortDirection = state.listingSortDirection === "desc" ? "asc" : "desc";
        renderListing(entries);
      };
      header.appendChild(textCell("Name"));
      header.appendChild(textCell("Size"));
      header.appendChild(modifiedButton);
      header.appendChild(textCell("Action"));
      listing.appendChild(header);

      if (!sortedEntries.length) {
        const empty = document.createElement("div");
        empty.className = "row";
        empty.innerHTML = "<div class='muted'>Empty directory</div><div></div><div></div><div></div>";
        listing.appendChild(empty);
        return;
      }

      for (const entry of sortedEntries) {
        const row = document.createElement("div");
        row.className = "row";

        const name = document.createElement("button");
        name.className = "name";
        name.textContent = (entry.isDirectory ? "[dir] " : "[file] ") + entry.name;
        name.title = entry.path;
        name.onclick = () => entry.isDirectory ? openDirectory(entry.path) : openFile(entry.path);

        const actions = document.createElement("div");
        actions.className = "actions";

        const download = document.createElement("button");
        download.textContent = "Download";
        download.onclick = () => downloadEntry(entry.path, entry.isDirectory).catch(handleError);

        const action = document.createElement("button");
        action.textContent = "Delete";
        action.onclick = () => confirmDelete(entry.path, entry.isDirectory);

        row.appendChild(name);
        row.appendChild(textCell(entry.isDirectory ? "" : formatBytes(entry.size)));
        row.appendChild(textCell(entryTime(entry) ? new Date(entryTime(entry)).toLocaleString() : ""));
        actions.appendChild(download);
        actions.appendChild(action);
        row.appendChild(actions);
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
      state.selectedKind = isImagePath(path)
        ? "image"
        : (isVideoPath(path)
          ? "video"
          : (isAudioPath(path)
            ? "audio"
            : (isPlistPath(path) ? "plist" : "text")));
      $("editorTitle").textContent = path;
      resetPreview();
      $("deleteButton").disabled = false;
      if (state.selectedKind === "image" || state.selectedKind === "video" || state.selectedKind === "audio") {
        const response = await fetch(api("/mkss/file?path=" + encodeURIComponent(path)));
        if (!response.ok) throw new Error(await response.text());
        const blob = await response.blob();
        if (state.selectedKind === "image") {
          renderImagePreview(blob, path);
        } else if (state.selectedKind === "video") {
          renderVideoPreview(blob, path);
        } else {
          renderAudioPreview(blob, path);
        }
        setEditorText("");
        $("editor").disabled = true;
        $("saveButton").disabled = true;
        setJSONEditorActive(false);
        return;
      }

      $("editor").disabled = false;
      $("saveButton").disabled = false;
      setJSONEditorActive(isJSONContext(path, state.selectedKind));
      if (state.selectedKind === "plist") {
        const payload = await requestJSON(api("/mkss/plist?path=" + encodeURIComponent(path)));
        setEditorText(JSON.stringify(payload.value, null, 2));
        showMessage("Loaded plist (" + payload.format + ") as editable JSON.");
        return;
      }
      setEditorText(await requestText(api("/mkss/file?path=" + encodeURIComponent(path))));
    }

    function confirmSave() {
      if (!state.selectedFile) return;
      const path = state.selectedFile;
      const content = $("editor").value;
      setConfirm("Confirm saving changes to " + path + "?", async () => {
        let endpoint = api("/mkss/file?path=" + encodeURIComponent(path));
        let body = content;
        if (state.selectedKind === "plist") {
          const parsed = parseJSONText(content);
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
          setEditorText("");
          $("editor").disabled = true;
          $("saveButton").disabled = true;
          $("deleteButton").disabled = true;
          $("editorTitle").textContent = "No file selected";
          setJSONEditorActive(false);
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

    async function openSpecialTarget(target) {
      clearConfirm();
      try {
        const info = await requestJSON(api("/mkss/stat?path=" + encodeURIComponent(target.path)));
        if (info.isDirectory) {
          await openDirectory(target.path);
        } else {
          await openDirectory(parentPath(target.path));
          await openFile(target.path);
        }
      } catch (error) {
        const fallbackPath = parentPath(target.path);
        if (fallbackPath && fallbackPath !== target.path) {
          await openDirectory(fallbackPath);
          showMessage("Shortcut target file was not found. Opened parent directory instead.", "warn");
          return;
        }
        throw error;
      }
    }

    async function downloadEntry(path, isDirectory) {
      if (isDirectory) {
        return downloadDirectory(path);
      }
      return downloadFile(path);
    }

    async function downloadFile(path, suggestedName) {
      const response = await fetch(api("/mkss/file?path=" + encodeURIComponent(path)));
      if (!response.ok) throw new Error(await response.text());
      const blob = await response.blob();
      const objectURL = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = objectURL;
      anchor.download = suggestedName || path.split("/").pop() || "download";
      document.body.appendChild(anchor);
      anchor.click();
      anchor.remove();
      window.setTimeout(() => URL.revokeObjectURL(objectURL), 2000);
    }

    async function downloadDirectory(path) {
      const listing = await requestJSON(api("/mkss/files?path=" + encodeURIComponent(path)));
      const files = [];
      await collectDirectoryFiles(listing.entries || [], path, files);
      if (!files.length) {
        showMessage("Directory is empty.", "warn");
        return;
      }
      setConfirm("Confirm downloading " + files.length + " file(s) from " + path + "?", async () => {
        for (const file of files) {
          await downloadFile(file.path, file.relativeName);
        }
        showMessage("Started downloading " + files.length + " file(s).");
      });
    }

    async function collectDirectoryFiles(entries, basePath, files) {
      for (const entry of entries) {
        if (entry.isDirectory) {
          const nested = await requestJSON(api("/mkss/files?path=" + encodeURIComponent(entry.path)));
          await collectDirectoryFiles(nested.entries || [], basePath, files);
          continue;
        }
        const relativeName = entry.path.startsWith(basePath + "/")
          ? entry.path.slice(basePath.length + 1).split("/").join("__")
          : (entry.name || entry.path.split("/").pop() || "download");
        files.push({
          path: entry.path,
          relativeName
        });
      }
    }

    async function confirmUploadFiles(files) {
      if (!state.currentPath || !state.currentPath.startsWith("/")) {
        showMessage("Select a directory before uploading files.", "warn");
        return;
      }

      const items = Array.from(files || []).filter(Boolean).map(file => ({
        file,
        relativePath: file.name
      }));

      if (!items.length) {
        showMessage("Choose at least one file to upload.", "warn");
        return;
      }

      const previewNames = items.slice(0, 5).map(item => item.relativePath).join(", ");
      const more = items.length > 5 ? " and " + (items.length - 5) + " more" : "";
      setConfirm("Confirm uploading " + items.length + " file(s) into " + state.currentPath + ": " + previewNames + more + "?", async () => {
        for (const item of items) {
          const targetPath = joinPath(state.currentPath, item.relativePath);
          await uploadBrowserFile(targetPath, item.file);
        }
        showMessage("Uploaded " + items.length + " file(s).");
        await openDirectory(state.currentPath);
      });
    }

    async function showLogs() {
      clearConfirm();
      state.currentPath = "(Logs)";
      state.selectedFile = null;
      state.selectedKind = "text";
      $("currentPath").textContent = "Logs";
      $("listing").innerHTML = "";
      $("editorTitle").textContent = "Logs";
      $("editor").disabled = false;
      $("saveButton").disabled = true;
      $("deleteButton").disabled = true;
      setJSONEditorActive(true);
      resetPreview();
      const data = await requestJSON(api("/mkss/logs"));
      setEditorText(JSON.stringify(data, null, 2));
    }

    $("reloadManifest").onclick = () => loadManifest().catch(handleError);
    $("rootsButton").onclick = () => loadManifest().catch(handleError);
    $("logsButton").onclick = () => showLogs().catch(handleError);
    $("refreshButton").onclick = () => {
      if (state.currentPath && state.currentPath.startsWith("/")) {
        openDirectory(state.currentPath).catch(handleError);
      }
    };
    $("toggleListingButton").onclick = toggleListing;
    $("upButton").onclick = () => {
      if (state.currentPath && state.currentPath.startsWith("/")) {
        openDirectory(parentPath(state.currentPath)).catch(handleError);
      }
    };
    $("saveButton").onclick = confirmSave;
    $("formatJSONButton").onclick = () => {
      try {
        setEditorText(formatJSONText(editorText()));
        showMessage("JSON formatted.");
      } catch (error) {
        showMessage("Invalid JSON: " + error.message, "error");
      }
    };
    $("jsonEditorButton").onclick = () => openJSONEditorDialog().catch(handleError);
    $("jsonEditorCloseButton").onclick = closeJSONEditorDialog;
    $("jsonEditorApplyButton").onclick = applyJSONEditorDialog;
    $("strictModeButton").onclick = () => {
      state.jsonParseMode = "strict";
      setJSONEditorActive(state.jsonEditorActive);
    };
    $("swiftModeButton").onclick = () => {
      state.jsonParseMode = "swift";
      setJSONEditorActive(state.jsonEditorActive);
    };
    $("fullscreenButton").onclick = toggleFullscreen;
    $("expandOutlineButton").onclick = () => setOutlineExpanded(true);
    $("collapseOutlineButton").onclick = () => setOutlineExpanded(false);
    $("deleteButton").onclick = () => {
      if (state.selectedFile) confirmDelete(state.selectedFile, false);
    };
    $("createFileButton").onclick = confirmCreateFile;
    $("createFolderButton").onclick = confirmCreateFolder;
    $("uploadFilesButton").onclick = () => $("uploadFilesInput").click();
    $("uploadFilesInput").onchange = () => {
      const files = Array.from($("uploadFilesInput").files || []);
      $("uploadFilesInput").value = "";
      confirmUploadFiles(files).catch(handleError);
    };
    $("dropzone").ondragover = event => {
      event.preventDefault();
      $("dropzone").classList.add("active");
    };
    $("dropzone").ondragleave = () => $("dropzone").classList.remove("active");
    $("dropzone").ondrop = event => prepareDroppedItems(event).catch(handleError);
    $("editor").oninput = refreshEditorChrome;
    $("editor").onscroll = () => {
      $("editorGutter").scrollTop = $("editor").scrollTop;
    };
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
    document.addEventListener("keydown", event => {
      if (event.key === "Escape" && $("jsonEditorOverlay").classList.contains("show")) {
        closeJSONEditorDialog();
        return;
      }
      if (event.key === "Escape" && state.editorFullscreen) {
        toggleFullscreen();
      }
    });

    function handleError(error) {
      showMessage(error.message || String(error), "error");
    }

    refreshEditorChrome();
    updateJSONModeButtons();
    loadManifest().catch(handleError);
  </script>
</body>
</html>
"""
}
#endif
