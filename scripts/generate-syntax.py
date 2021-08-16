#!/usr/bin/env python3

import requests
import xml.etree.ElementTree as xml
from dataclasses import dataclass
from typing import List, Tuple

ECL_LANGUAGE_REF_VERSION = "d965fc1df69a9933578e6b2f1076f2f8689d7932"


def get_language_reference() -> List[xml.Element]:
    url = (
        "https://raw.githubusercontent.com/hpcc-systems/eclide/"
        + ECL_LANGUAGE_REF_VERSION
        + "/docs/LanguageRefECL.xml"
    )
    response = requests.get(url)
    return xml.fromstring(response.text).findall(".//item")


@dataclass
class Item:
    category: int
    name: str
    tooltip: str
    insert_before_cursor: str
    insert_after_cursor: str
    can_be_followed_by: str

    @classmethod
    def from_element(cls, el: xml.Element) -> "Item":
        return cls(
            int(el.findtext("categoryid")),
            el.findtext("name"),
            el.findtext("tooltip"),
            el.findtext("insertbeforecursor"),
            el.findtext("insertaftercursor"),
            el.findtext("canbefollowedby"),
        )

    @classmethod
    def fetch_all(cls) -> List["Item"]:
        return list(map(cls.from_element, get_language_reference()))


class Syntax:
    @staticmethod
    def keyword(item: Item) -> Tuple[str, str]:
        return (
            "syntax keyword ecl_keyword " + item.name,
            "highlight default link ecl_keyword Keyword",
        )

    @staticmethod
    def special(item: Item) -> Tuple[str, str]:
        return (
            r"syntax match ecl_special /\<{}\>/".format(item.name),
            "highlight default link ecl_special Special",
        )

    @staticmethod
    def type(item: Item) -> Tuple[str, str]:
        name = item.name
        followed_by = item.can_be_followed_by

        if followed_by.endswith("#_#"):
            name += r"\(\d\+_\d\+\)\?"

        elif followed_by.endswith("#") or followed_by.endswith("#|"):
            name += r"\d*"

        elif followed_by.endswith("|"):
            opts = followed_by[:-2].split(",")
            name += r"\({}\)\?".format(r"\|".join(opts))

        return (
            r"syntax match ecl_type /\<{}\>/".format(name),
            "highlight default link ecl_type Type",
        )

    @staticmethod
    def macro(item: Item) -> Tuple[str, str]:
        return (
            r"syntax match ecl_macro /#[a-z0-9_]\+/",
            "highlight default link ecl_macro Macro",
        )


if __name__ == "__main__":
    import sys

    if "--completions" in sys.argv:
        completions = set()
        for item in Item.fetch_all():
            if len(item.name.split()) == 1:
                completions.add(item.name)
        print("\n".join(sorted(completions)))
        exit()

    handlers = {
        1: Syntax.special,
        2: Syntax.keyword,
        3: Syntax.keyword,
        4: Syntax.type,
        5: Syntax.keyword,
        6: Syntax.macro,
    }

    rules = [
        '" generated from language reference ' + ECL_LANGUAGE_REF_VERSION,
        "syntax clear",
        "syntax include @cpp syntax/cpp.vim",
        "syntax case ignore",
        "syntax region ecl_cpp matchgroup=Keyword start=/beginc++/ end=/endc++/ contains=@cpp",
        r"syntax region ecl_string start=/'/ skip=/\\'/ end=/'/ oneline",
        r"syntax region ecl_comment_block start='/\*' end='\*/'",
        r"syntax match ecl_comment_line /\/\/.*/",
    ]

    highlights = [
        "highlight default link ecl_string String",
        "highlight default link ecl_comment_block Comment",
        "highlight default link ecl_comment_line Comment",
    ]

    for item in Item.fetch_all():
        if item.name in ("BEGINC", "ENDC"):
            continue

        rule, highlight = handlers[item.category](item)

        if rule not in rules:
            rules.append(rule)

        if highlight not in highlights:
            highlights.append(highlight)

    print("\n".join(rules))
    print("\n".join(highlights))
