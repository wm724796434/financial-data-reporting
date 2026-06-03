---
name: ocr-and-documents
description: "Extract text from PDFs/scans (pymupdf, marker-pdf)."
version: 2.3.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [PDF, Documents, Research, Arxiv, Text-Extraction, OCR]
    related_skills: [powerpoint]
---

# PDF & Document Extraction

For DOCX: use `python-docx` (parses actual document structure, far better than OCR).
For PPTX: see the `powerpoint` skill (uses `python-pptx` with full slide/notes support).
This skill covers **PDFs and scanned documents**.

## Step 1: Remote URL Available?

If the document has a URL, **always try `web_extract` first**:

```
web_extract(urls=["https://arxiv.org/pdf/2402.03300"])
web_extract(urls=["https://example.com/report.pdf"])
```

This handles PDF-to-markdown conversion via Firecrawl with no local dependencies.

Only use local extraction when: the file is local, web_extract fails, or you need batch processing.

## Step 2: Choose Local Extractor

| Feature | pymupdf (~25MB) | marker-pdf (~3-5GB) |
|---------|-----------------|---------------------|
| **Text-based PDF** | ✅ | ✅ |
| **Scanned PDF (OCR)** | ❌ | ✅ (90+ languages) |
| **Tables** | ✅ (basic) | ✅ (high accuracy) |
| **Equations / LaTeX** | ❌ | ✅ |
| **Code blocks** | ❌ | ✅ |
| **Forms** | ❌ | ✅ |
| **Headers/footers removal** | ❌ | ✅ |
| **Reading order detection** | ❌ | ✅ |
| **Images extraction** | ✅ (embedded) | ✅ (with context) |
| **Images → text (OCR)** | ❌ | ✅ |
| **EPUB** | ✅ | ✅ |
| **Markdown output** | ✅ (via pymupdf4llm) | ✅ (native, higher quality) |
| **Install size** | ~25MB | ~3-5GB (PyTorch + models) |
| **Speed** | Instant | ~1-14s/page (CPU), ~0.2s/page (GPU) |

**Decision**: Use pymupdf unless you need OCR, equations, forms, or complex layout analysis.

If the user needs marker capabilities but the system lacks ~5GB free disk:
> "This document needs OCR/advanced extraction (marker-pdf), which requires ~5GB for PyTorch and models. Your system has [X]GB free. Options: free up space, provide a URL so I can use web_extract, or I can try pymupdf which works for text-based PDFs but not scanned documents or equations."

---

## pymupdf (lightweight)

```bash
pip install pymupdf pymupdf4llm
```

**Via helper script**:
```bash
python scripts/extract_pymupdf.py document.pdf              # Plain text
python scripts/extract_pymupdf.py document.pdf --markdown    # Markdown
python scripts/extract_pymupdf.py document.pdf --tables      # Tables
python scripts/extract_pymupdf.py document.pdf --images out/ # Extract images
python scripts/extract_pymupdf.py document.pdf --metadata    # Title, author, pages
python scripts/extract_pymupdf.py document.pdf --pages 0-4   # Specific pages
```

**Inline**:
```bash
python3 -c "
import pymupdf
doc = pymupdf.open('document.pdf')
for page in doc:
    print(page.get_text())
"
```

---

## Lightweight OCR: pdftoppm + tesseract (when marker-pdf is too heavy)

Use this when: the PDF is a **scanned image** (no text layer), you need **Chinese/Japanese/Korean** OCR, and marker-pdf's ~3-5GB model download is impractical.

**Install**:

```bash
# Ubuntu/Debian
sudo apt-get install -y tesseract-ocr

# Chinese simplified (for 金数/EAST docs)
sudo apt-get install -y tesseract-ocr-chi-sim

# Other languages
sudo apt-get install -y tesseract-ocr-jpn   # Japanese
sudo apt-get install -y tesseract-ocr-kor   # Korean

# Python wrapper (for programmatic use)
pip3 install --break-system-packages pytesseract pdf2image
```

**Detect if OCR is needed**:

```bash
# If pdftotext returns empty → it's a scanned image
pdftotext -layout document.pdf - | head -5

# Check PDF metadata
pdfinfo document.pdf | grep -i "producer"
# "CamScanner" or "intsig.com" → scanned image
```

**Pipeline**:

```bash
# Step 1: Convert PDF pages to JPEG images
mkdir -p /tmp/pdf_pages
pdftoppm -jpeg -r 300 document.pdf /tmp/pdf_pages/page

# Step 2: OCR each page with tesseract
for i in $(seq -w 1 $(pdfinfo document.pdf | grep Pages | awk '{print $2}')); do
    tesseract /tmp/pdf_pages/page-$i.jpg stdout -l chi_sim 2>/dev/null
done > /tmp/ocr_output.txt
```

**Python automation** (for structured output):

```python
from pdf2image import convert_from_path
import pytesseract

images = convert_from_path("document.pdf", dpi=300)
full_text = []
for i, img in enumerate(images):
    text = pytesseract.image_to_string(img, lang='chi_sim')
    full_text.append(f"\n=== Page {i+1} ===\n{text}")
```

**⚠️ Critical Pitfall: formatting OCR output**

OCR text is structurally unpredictable — page breaks split words mid-line, special characters are garbled, and repeated patterns like "金融机构代码" may appear misspelled in dozens of inconsistent ways. **Never use bulk find-replace with `replace_all=True` on OCR output.** A single over-broad replacement can corrupt the entire document.

**Concrete failure example (from real session):**

When cleaning OCR of a Chinese financial document, applying `replace_all=True` on "借借款人" → "借款人" triggered a cascading mutation: the tool also matched and replaced unrelated fragments inside table data rows, which then caused subsequent fix patterns to fire on corrupted text. The result was hundreds of repeated lines like `#### 2. 金融机构地区代码` injected at every page break throughout the document. The file was irrecoverable and had to be deleted and rebuilt from scratch.

**Recovery procedure (when corruption happens):**

1. **Delete the corrupted file immediately** — don't try to patch over corruption
2. **Rebuild from raw OCR output** using a Python script that processes line by line, never using `patch` on the output
3. **Do safe dictionary-based replacements FIRST** before structuring:
   ```python
   safe_fixes = {"wrong": "correct"}
   for wrong, correct in safe_fixes.items():
       raw_text = raw_text.replace(wrong, correct)
   ```
4. **Then build structure** by iterating lines and applying rules per line (title detection, list detection, etc.)
5. **Keep fixes minimal** — fix only the most egregious OCR errors; trying to perfect every character wastes time and risks corruption

**Safe workflow:**

1. Run safe dictionary replacements on raw text BEFORE structuring
2. Build the output document line-by-line from cleaned raw OCR using Python, not patch tools
3. Do targeted fixes on specific lines, not global search-and-replace
4. Verify output visually after each fix batch — check the first 50 lines, then a sample from the middle and end

---

## marker-pdf (high-quality OCR)

```bash
# Check disk space first
python scripts/extract_marker.py --check

pip install marker-pdf
```

**Via helper script**:
```bash
python scripts/extract_marker.py document.pdf                # Markdown
python scripts/extract_marker.py document.pdf --json         # JSON with metadata
python scripts/extract_marker.py document.pdf --output_dir out/  # Save images
python scripts/extract_marker.py scanned.pdf                 # Scanned PDF (OCR)
python scripts/extract_marker.py document.pdf --use_llm      # LLM-boosted accuracy
```

**CLI** (installed with marker-pdf):
```bash
marker_single document.pdf --output_dir ./output
marker /path/to/folder --workers 4    # Batch
```

---

## Arxiv Papers

```
# Abstract only (fast)
web_extract(urls=["https://arxiv.org/abs/2402.03300"])

# Full paper
web_extract(urls=["https://arxiv.org/pdf/2402.03300"])

# Search
web_search(query="arxiv GRPO reinforcement learning 2026")
```

## Split, Merge & Search

pymupdf handles these natively — use `execute_code` or inline Python:

```python
# Split: extract pages 1-5 to a new PDF
import pymupdf
doc = pymupdf.open("report.pdf")
new = pymupdf.open()
for i in range(5):
    new.insert_pdf(doc, from_page=i, to_page=i)
new.save("pages_1-5.pdf")
```

```python
# Merge multiple PDFs
import pymupdf
result = pymupdf.open()
for path in ["a.pdf", "b.pdf", "c.pdf"]:
    result.insert_pdf(pymupdf.open(path))
result.save("merged.pdf")
```

```python
# Search for text across all pages
import pymupdf
doc = pymupdf.open("report.pdf")
for i, page in enumerate(doc):
    results = page.search_for("revenue")
    if results:
        print(f"Page {i+1}: {len(results)} match(es)")
        print(page.get_text("text"))
```

No extra dependencies needed — pymupdf covers split, merge, search, and text extraction in one package.

---

## Notes

- `web_extract` is always first choice for URLs
- pymupdf is the safe default — instant, no models, works everywhere
- marker-pdf is for OCR, scanned docs, equations, complex layouts — install only when needed
- Both helper scripts accept `--help` for full usage
- marker-pdf downloads ~2.5GB of models to `~/.cache/huggingface/` on first use
- For Word docs: `pip install python-docx` (better than OCR — parses actual structure)
- For PowerPoint: see the `powerpoint` skill (uses python-pptx)
