#!/usr/bin/env python3
##written by RK with chatgpt
"""
Combine BLAST result SVG plots into a single PDF.

Dependencies
------------
pip install cairosvg Pillow fpdf2 pandas
"""

import io
import os
import tempfile
from pathlib import Path

import cairosvg          # SVG ➜ PNG rasteriser
import pandas as pd
from fpdf import FPDF     # PDF builder
from PIL import Image     # to read PNG dimensions


# ----------------------- helpers --------------------------------------------
def px_to_mm(px: int, *, dpi: int) -> float:
    """Convert pixels to millimetres at the specified resolution."""
    return px * (25.4 / dpi)


# ----------------------- main routine ---------------------------------------
def main(
    table_path: str = "SI tables/SI table 2.tsv",
    svg_dir: str = "outputs/blast_result_plots_no_arthropod",
    pdf_out: str = "outputs/combined_blastplots.pdf",
    dpi: int = 300,                   # raster DPI (higher → better quality)
) -> None:

    # 1.  Load metadata -------------------------------------------------------
    df = pd.read_csv(table_path, sep="\t", index_col=0)

    # 2.  Determine which SVGs we actually have ------------------------------
    svg_basenames = {
        Path(f).stem for f in os.listdir(svg_dir) if f.lower().endswith(".svg")
    }
    targets = sorted(set(df[df.representative].index) & svg_basenames)
    if not targets:
        raise SystemExit("No overlapping representative genes & SVG plots found.")

    # 3.  Set up PDF ----------------------------------------------------------
    pdf = FPDF(unit="mm", format="A4")
    pdf.set_auto_page_break(auto=True, margin=15)

    # 4.  Iterate through each gene -----------------------------------------
    for gene in targets:
        species = df.at[gene, "species"]
        cluster = df.at[gene, "cluster"]
        title = f"{species} {gene} (cluster {cluster})"
        svg_path = os.path.join(svg_dir, f"{gene}.svg")

        # --- rasterise SVG -> PNG bytes in-memory ---------------------------
        png_bytes = cairosvg.svg2png(url=svg_path, dpi=dpi)
        img = Image.open(io.BytesIO(png_bytes))
        img_w_mm = px_to_mm(img.width, dpi=dpi)
        img_h_mm = px_to_mm(img.height, dpi=dpi)

        # --- add a new PDF page & place header ------------------------------
        pdf.add_page()
        pdf.set_font("Arial", size=11)
        pdf.cell(0, 10, txt=title, ln=True, align="C")

        # --- work out maximum drawable area ---------------------------------
        max_w = pdf.w - 2 * pdf.l_margin
        max_h = pdf.h - (pdf.t_margin + 20) - pdf.b_margin
        scale = min(max_w / img_w_mm, max_h / img_h_mm, 1.0)
        draw_w = img_w_mm * scale
        draw_h = img_h_mm * scale

        # --- FPDF needs an actual file path; use a temp PNG -----------------
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as tmp:
            tmp.write(png_bytes)
            tmp.flush()
            pdf.image(
                tmp.name,
                x=pdf.l_margin,
                y=pdf.t_margin + 20,
                w=draw_w,
                h=draw_h,
            )
        os.unlink(tmp.name)  # tidy up temp file

    # 5.  Write final PDF ----------------------------------------------------
    Path(pdf_out).parent.mkdir(parents=True, exist_ok=True)
    pdf.output(pdf_out)
    print(f"PDF generated successfully ➜ {pdf_out}")


main()
