import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import os

# --------------------------------------------------
# CONFIG
# --------------------------------------------------
TESTS = [
    {
        "title": "Test 1 – Simple street with slope",
        "input": "txt/input_test1_slope.txt",
        "mask":  "txt/mask_test1_slope.txt",
        "flip_for_display": False
    },
    {
        "title": "Test 2 – Simple street with obstacle",
        "input": "txt/input_test2_obstacle.txt",
        "mask":  "txt/mask_test2_obstacle.txt",
        "flip_for_display": False
    },
    {
        "title": "Test 3 – Simplified car perspective",
        "input": "txt/input_perspective.txt",
        "mask":  "txt/mask_perspective.txt",
        "flip_for_display": True 
    }
]

GROUND_CMAP = ListedColormap(["red", "green"])

# --------------------------------------------------
# HELPER
# --------------------------------------------------
def load_matrix(path):
    if not os.path.exists(path):
        raise FileNotFoundError(f"File not found: {path}")
    return np.loadtxt(path)

# --------------------------------------------------
# MAIN VISUALIZATION
# --------------------------------------------------
for test in TESTS:

    title = test["title"]
    input_file = test["input"]
    mask_file = test["mask"]
    flip = test["flip_for_display"]

    # Load data
    R = load_matrix(input_file)
    mask = load_matrix(mask_file)

    # --------------------------------------------------
    # IMPORTANT:
    # Algorithm convention:
    #   y = 0   -> sky / far
    #   y = end -> ground / near
    #
    # For visualization we want:
    #   ground at the bottom of the image
    #
    # => flip ONLY for display when needed
    # --------------------------------------------------
    if flip:
        R = np.flipud(R)
        mask = np.flipud(mask)

    # Auto scale (ignore zeros)
    if np.any(R > 0):
        vmin = R[R > 0].min()
        vmax = R.max()
    else:
        vmin, vmax = 0, 1

    # --------------------------------------------------
    # Plot
    # --------------------------------------------------
    fig, axes = plt.subplots(1, 2, figsize=(11, 6))
    fig.suptitle(title, fontsize=14)

    # Input range image
    im1 = axes[0].imshow(
        R,
        cmap="viridis",
        vmin=vmin,
        vmax=vmax,
        interpolation="nearest",
        aspect="auto",
        origin="upper"   # IMPORTANT: ground at bottom
    )
    axes[0].set_title("Input LiDAR Range Image")
    axes[0].set_xlabel("X (azimuth)")
    axes[0].set_ylabel("Y (elevation)")
    fig.colorbar(im1, ax=axes[0], label="Range")

    # Ground mask
    im2 = axes[1].imshow(
        mask,
        cmap=GROUND_CMAP,
        vmin=0,
        vmax=1,
        interpolation="nearest",
        aspect="auto",
        origin="upper"   # IMPORTANT
    )
    axes[1].set_title("Ground Segmentation")
    axes[1].set_xlabel("X (azimuth)")
    axes[1].set_ylabel("Y (elevation)")
    cbar = fig.colorbar(im2, ax=axes[1], ticks=[0, 1])
    cbar.ax.set_yticklabels(["Non-ground", "Ground"])

    plt.tight_layout()
    plt.show()

print("Visualization finished successfully.")
