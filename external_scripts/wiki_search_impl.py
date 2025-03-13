import argparse
import wikipedia
import wikipediaapi
import time
import pprint
import json
import requests
import sys
sys.stdout.reconfigure(encoding='utf-8')
import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def search_by_wiki(term, mode):
    page = wikipedia.page(term)
    if mode == 'summary':
        result = page.summary
    elif mode == 'content':
        result = page.content
    else:
        result = page.html
    return result


def search_by_wiki_api(term, mode):
    extract_format = wikipediaapi.ExtractFormat.HTML if mode == 'html' else wikipediaapi.ExtractFormat.WIKI
    wiki_wiki = wikipediaapi.Wikipedia(
        'MyProjectName (merlin@example.com)',
        'en',
        extract_format=extract_format,
        verify=False
    )

    page = wiki_wiki.page(term)
    if not page.exists():
        return "Nothing Found"

    if mode == 'summary':
        result = page.summary
    elif mode == 'content':
        result = page.text
    else:
        result = page.text
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Wiki Search Tool.')
    parser.add_argument('--query', dest='query', action='store', required=True,
                        help='The query to search')
    parser.add_argument('--mode', dest='mode', action='store',
                        choices=['summary', 'content', 'html'],
                        default='summary')
    args = parser.parse_args()

    time.sleep(2)
    search_results: list[str] = wikipedia.search(args.query)
    # print(search_results)
    if search_results:
        # The first search result as the title
        term = search_results[0]
        time.sleep(3)
        # result = search_by_wiki(term, args.mode)
        result = search_by_wiki_api(term, args.mode)
        print(result) # .encode('gbk', errors='ignore').decode('gbk'))
    else:
        print("Nothing found")