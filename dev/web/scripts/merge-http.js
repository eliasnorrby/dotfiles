#!/usr/bin/env node
import fs from "fs";

const GENERATED = "api.localhost.http";
const TARGET = "api.http";

// Split on lines that are exactly "###"
function splitOnSeparators(content) {
  return content
    .split(/^\s*###\s*$/m)
    .map((s) => s.trim())
    .filter(Boolean);
}

function readHttpFile(file) {
  if (!fs.existsSync(file)) return { preamble: "", blocks: [] };
  const content = fs.readFileSync(file, "utf8");
  const parts = splitOnSeparators(content);

  let preamble = "";
  const blocks = [];
  for (const part of parts) {
    if (!preamble && !part.startsWith("# @name")) {
      preamble = part;
    } else {
      blocks.push(part);
    }
  }
  return { preamble, blocks };
}

function parseBlocks(blocks) {
  return blocks.map((block) => {
    const clean = block.replace(/^\s+/, "").trim();
    const match = clean.match(/^# @name (\S+)/m);
    return { name: match?.[1] ?? null, block: clean };
  });
}

function cleanPreamble(preamble) {
  if (!preamble) return "";
  const lines = preamble.split(/\r?\n/);
  const out = [];
  let seenBaseUrl = false;
  for (const line of lines) {
    if (/^\s*###\s*$/.test(line)) continue; // strip accidental separators
    if (/^\s*@baseUrl\b/.test(line)) {
      if (seenBaseUrl) continue;
      seenBaseUrl = true;
    }
    out.push(line);
  }
  return out.join("\n").trim();
}

// --- Read files ---
const gen = readHttpFile(GENERATED);
const existing = readHttpFile(TARGET);

// --- Merge preamble ---
const preamble = cleanPreamble(existing.preamble || gen.preamble || "");

// --- Merge blocks ---
const genBlocks = parseBlocks(gen.blocks);
const exBlocks = parseBlocks(existing.blocks);
const existingMap = new Map(
  exBlocks.filter((b) => b.name).map((b) => [b.name, b.block]),
);

const mergedBlocks = [];
const addedNames = [];

for (const g of genBlocks) {
  if (g.name && existingMap.has(g.name)) {
    mergedBlocks.push(existingMap.get(g.name)); // keep edits
    existingMap.delete(g.name);
  } else {
    mergedBlocks.push(g.block);
    if (g.name) addedNames.push(g.name); // track additions
  }
}

// Keep leftover blocks (optional)
for (const leftover of existingMap.values()) {
  mergedBlocks.push(leftover);
}

// --- Build final output (Kulala spacing: two newlines between requests) ---
const finalContent =
  (preamble ? `###\n\n${preamble}\n\n\n` : "") +
  mergedBlocks.map((b) => `###\n\n${b.trim()}`).join("\n\n\n") +
  "\n";

// --- Only write if something new was added ---
const currentContent = fs.existsSync(TARGET)
  ? fs.readFileSync(TARGET, "utf8")
  : "";

if (addedNames.length === 0) {
  console.log("✅ No new endpoints. File left untouched.");
  process.exit(0);
}

if (currentContent.trim() === finalContent.trim()) {
  console.log("✅ No structural changes. File left untouched.");
  process.exit(0);
}

// --- Write merged file ---
fs.writeFileSync(TARGET, finalContent);
console.log(`✅ Added endpoints: ${addedNames.join(", ")}`);
