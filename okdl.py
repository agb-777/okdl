#!/usr/bin/env python3

import argparse
import re
import sys

try:
    import yt_dlp
    from yt_dlp.extractor.odnoklassniki import OdnoklassnikiIE
except ImportError:
    sys.stderr.write("Error: 'yt-dlp' module not found. Install with: pip install yt-dlp\n")
    sys.exit(1)

DEFAULT_FORMAT = "best"
DEFAULT_OUTPUT = "%(title)s.%(ext)s"


def patch_okru_extractor():
    try:
        original = OdnoklassnikiIE._parse_json

        def patched(self, json_string, video_id, *args, **kwargs):
            if isinstance(json_string, dict):
                return json_string
            return original(self, json_string, video_id, *args, **kwargs)

        OdnoklassnikiIE._parse_json = patched
    except AttributeError:
        pass


def normalize_url(url):
    match = re.search(r"/video/(\d+)", url)
    return f"https://ok.ru/video/{match.group(1)}" if match else url


def build_ydl_options(args):
    options = {
        "quiet": not args.verbose,
        "verbose": args.verbose,
        "nocheckcertificate": True,
        "no_warnings": not args.verbose,
    }

    if args.list_formats:
        options["listformats"] = True
    else:
        options["format"] = args.format
        options["outtmpl"] = args.output

    return options


def run_download(url, options):
    with yt_dlp.YoutubeDL(options) as ydl:
        ydl.download([url])


def parse_args():
    parser = argparse.ArgumentParser(
        description="Download videos from OK.ru",
    )

    parser.add_argument("-u", "--url", required=True, help="Target OK.ru video URL")
    parser.add_argument("-F", "--list-formats", action="store_true", help="List available formats and exit")
    parser.add_argument("-f", "--format", default=DEFAULT_FORMAT, help=f"Select format. Default: {DEFAULT_FORMAT}")
    parser.add_argument("-o", "--output", default=DEFAULT_OUTPUT, help=f"Output filename template. Default: {DEFAULT_OUTPUT.replace('%', '%%')}")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")

    return parser.parse_args()


def main():
    patch_okru_extractor()
    args = parse_args()
    url = normalize_url(args.url)
    options = build_ydl_options(args)

    try:
        run_download(url, options)
    except yt_dlp.utils.DownloadError as error:
        sys.stderr.write(f"Error: {error}\n")
        sys.exit(1)
    except Exception as error:
        sys.stderr.write(f"Error: {error}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
