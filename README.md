# UET Graduation Thesis Template

A **Markdown-first** writing workflow for your graduation thesis at University of Engineering and Technology, Vietnam National University.

> ✍️ Write in Markdown with **Obsidian** → 🔄 Convert with **Pandoc** → 📄 Output professional **LaTeX/PDF**

## ✨ Features

- **Write in Markdown** using Obsidian as your editor
- **Convert to LaTeX** using Pandoc
- Auto numbering of pages, chapters, sections, and subsections
- Automatic table of contents, list of figures and tables
- **Zotero integration** for citation management
- Support for Vietnamese language
- IEEE citation style

## 📁 Project Structure

```
thesis/
├── content/              # 📝 Write your thesis here (Markdown)
│   ├── 00-introduction.md
│   ├── 01-chapter1.md
│   ├── ...
│   └── frontmatter/
├── templates/            # 📋 Obsidian & Pandoc templates
├── build/                # 🔧 Build scripts
├── chapter/              # 📄 Generated LaTeX (don't edit directly)
├── cover/                # 📑 Cover pages (LaTeX)
├── figures/              # 🖼️ Images
├── references.bib        # 📚 Bibliography
└── main.tex              # 📘 Main LaTeX file
```

## 🚀 Quick Start

### Prerequisites

1. **Pandoc** - Document converter
   ```bash
   # Ubuntu/Debian
   sudo apt install pandoc

   # macOS
   brew install pandoc

   # Or download from https://pandoc.org/installing.html
   ```

2. **LaTeX Distribution**
   ```bash
   # Ubuntu/Debian
   sudo apt install texlive-full

   # macOS
   brew install --cask mactex
   ```

3. **Obsidian** (optional but recommended)
   - Download from https://obsidian.md

4. **Zotero** (for citations)
   - Download from https://www.zotero.org
   - Install **Better BibTeX** plugin

### Writing Your Thesis

1. **Open in Obsidian**: Open the `thesis` folder as an Obsidian vault

2. **Edit Markdown files** in `content/` directory:
   ```markdown
   ---
   title: "Chapter Title"
   chapter: 1
   ---
   
   # Chapter Title
   
   Your content here...
   
   ## Section
   
   - Use standard Markdown syntax
   - Add citations like this [@Cockburn2005]
   - Math equations: $E = mc^2$
   ```

3. **Add images** to `figures/` folder, reference them as:
   ```markdown
   ![Caption](../figures/image.png)
   ```

4. **Add citations** to `references.bib` (or export from Zotero)

### Building the Thesis

```bash
# Convert Markdown to LaTeX
make convert

# Build PDF (runs convert + pdflatex)
make all

# Full build with bibliography
make full

# Or manually:
./build/build.sh
pdflatex main.tex
```

## 📝 Markdown Syntax Guide

| Element | Markdown | LaTeX Output |
|---------|----------|--------------|
| Heading | `# Title` | `\chapter{}` |
| Section | `## Section` | `\section{}` |
| Bold | `**text**` | `\textbf{}` |
| Italic | `*text*` | `\textit{}` |
| Citation | `[@key]` | `\cite{key}` |
| Math | `$x^2$` | `$x^2$` |
| Image | `![caption](path)` | `\includegraphics` |

## 🔌 Recommended Obsidian Plugins

| Plugin | Purpose |
|--------|---------|
| **Templater** | Insert chapter templates quickly |
| **Longform** | Manage thesis as a single project |
| **Citations** | Insert citations from Zotero |
| **Pandoc Plugin** | Export directly from Obsidian |

## 📚 Citation Workflow with Zotero

1. Install **Better BibTeX** plugin in Zotero
2. Export library: `File → Export Library → Better BibTeX`
3. Save as `references.bib` in thesis folder
4. In Markdown, cite as: `[@AuthorYear]`

## 🙏 Special Thanks

This repository is forked from the amazing work by **[@huythai855](https://github.com/huythai855)**!

If you find this template useful, please consider giving a ⭐ to the **original repository** to support the author:

👉 **[huythai855/uet-graduation-thesis-template](https://github.com/huythai855/uet-graduation-thesis-template)**

## 🔗 References

- [UET Thesis Guidelines](https://uet.vnu.edu.vn/mau-bieu-ve-trinh-bay-khoa-luan-tot-nghiep-va-tot-nghiep-cho-sinh-vien/)
- [Pandoc User Guide](https://pandoc.org/MANUAL.html)
- [Obsidian Documentation](https://help.obsidian.md)
- [DoHaiSon/Graduate_Thesis](https://github.com/DoHaiSon/Graduate_Thesis)