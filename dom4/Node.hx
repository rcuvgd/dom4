/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is dom4 code.
 *
 * The Initial Developer of the Original Code is
 * Disruptive Innovations SAS
 * Portions created by the Initial Developer are Copyright (C) 2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Daniel Glazman <daniel.glazman@disruptive-innovations.com>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */


package dom4;

class Node extends EventTarget {
  
  public static inline var ELEMENT_NODE: Int = 1;
  public static inline var ATTRIBUTE_NODE: Int = 2;
  public static inline var TEXT_NODE: Int = 3;
  public static inline var CDATA_SECTION_NODE: Int = 4;
  public static inline var ENTITY_REFERENCE_NODE: Int = 5;
  public static inline var ENTITY_NODE: Int = 6;
  public static inline var PROCESSING_INSTRUCTION_NODE: Int = 7;
  public static inline var COMMENT_NODE: Int = 8;
  public static inline var DOCUMENT_NODE: Int = 9;
  public static inline var DOCUMENT_TYPE_NODE: Int = 10;
  public static inline var DOCUMENT_FRAGMENT_NODE: Int = 11;
  public static inline var NOTATION_NODE: Int = 12;

  public static inline var DOCUMENT_POSITION_DISCONNECTED: Int = 0x01;
  public static inline var DOCUMENT_POSITION_PRECEDING: Int = 0x02;
  public static inline var DOCUMENT_POSITION_FOLLOWING: Int = 0x04;
  public static inline var DOCUMENT_POSITION_CONTAINS: Int = 0x08;
  public static inline var DOCUMENT_POSITION_CONTAINED_BY: Int = 0x10;
  public static inline var DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC: Int = 0x20;

  public var nodeType(default, null): Int;
  public var nodeName(default, null): DOMString;

  public var baseURI(default, null): DOMString;

  public var ownerDocument(default, null): Document;
  public var parentNode(default, null): Node;
  public var parentElement(get, null): Element;
      private function get_parentElement() : Element
      {
        return ((this.parentNode.nodeType == ELEMENT_NODE)
                ? cast(this.parentNode, Element)
                : null);
      }
  public function hasChildNodes(): Bool
  {
    return (null != this.firstChild);
  }
  public var childNodes(get, null): NodeList;
      private function get_childNodes(): NodeList
      {
        return new NodeList(this.firstChild);
      }
  public var firstChild(default, null): Node;
  public var lastChild(default, null): Node;
  public var previousSibling(default, null): Node;
  public var nextSibling(default, null): Node;

  public var firstElementChild(get, null): Node;
      private function get_firstElementChild(): Node
      {
        var child = this.firstChild;
        while (child != null) {
          if (child.nodeType == ELEMENT_NODE)
            return child;
          child = child.nextSibling;
        }
        return null;
      }
  public var lastElementChild(get, null): Node;
      private function get_lastElementChild(): Node
      {
        var child = this.lastChild;
        while (child != null) {
          if (child.nodeType == ELEMENT_NODE)
            return child;
          child = child.previousSibling;
        }
        return null;
      }
  public var previousElementSibling(get, null): Node;
      private function get_previousElementSibling(): Node
      {
        var node = this.previousSibling;
        while (node != null) {
          if (node.nodeType == ELEMENT_NODE)
            return node;
          node = node.previousSibling;
        }
        return null;
      }
  public var nextElementSibling(get, null): Node;
      private function get_nextElementSibling(): Node
      {
        var node = this.nextSibling;
        while (node != null) {
          if (node.nodeType == ELEMENT_NODE)
            return node;
          node = node.nextSibling;
        }
        return null;
      }
  public var nodeValue(get, set): DOMString;
      private function get_nodeValue(): DOMString
      {
        switch (this.nodeType) {
          case TEXT_NODE | PROCESSING_INSTRUCTION_NODE | COMMENT_NODE:
            return cast(this, CharacterData).data;
          case _:
            return null;
        }
      }
      private function set_nodeValue(v: DOMString): DOMString
      {
        switch (this.nodeType) {
          case TEXT_NODE | PROCESSING_INSTRUCTION_NODE | COMMENT_NODE:
            cast(this, CharacterData).data = v;
        }
        return v;
      }
  public var textContent(get, set): DOMString;
      private function get_textContent(): DOMString
      {
        var rv = this.nodeValue;
        if (rv == null) {
          rv = "";
          var n = this.firstChild;
          while (n != null) {
            rv += n.textContent;
            n = n.nextSibling;
          }
        }
        return rv;
      }
      private function set_textContent(v: DOMString): DOMString
      {
        switch (this.nodeType) {
          case TEXT_NODE | PROCESSING_INSTRUCTION_NODE | COMMENT_NODE:
            cast(this, CharacterData).data = v;
          case ELEMENT_NODE: {
            this.firstChild = new Text(v);
            this.lastChild = this.firstChild;
          }
          case _:{}
        }
        return v;
      }
  public function normalize(): Void
  {
    var node = firstChild;
    while (node != null) {
      switch (node.nodeType) {
        case TEXT_NODE: {
          if (node.nextSibling != null && node.nextSibling.nodeType == TEXT_NODE) {
            var currentNode = node;
            var data = "";
            while (currentNode != null && currentNode.nodeType == TEXT_NODE) {
              data += cast(currentNode, CharacterData).data;
              currentNode = currentNode.nextSibling;
            }
            var newTextNode = new Text(data);
            if (node.parentNode != null && node.parentNode.firstChild == node)
              node.parentNode.firstChild = newTextNode;
            if (node.parentNode != null) {
              if (currentNode == null)
                node.parentNode.lastChild = newTextNode;
            }
            newTextNode.previousSibling = node.previousSibling;
            newTextNode.nextSibling = currentNode;
          }
        }
      case ELEMENT_NODE: node.normalize();
      }
    }
  }

  public function cloneNode(?deep: Bool = false) : Node
  {
    // TBD
    return null;
  }
  public function isEqualNode(node: Node): Bool
  {
    return (node == this);
  }

  public function compareDocumentPosition(other: Node): Int
  {
    // TBD
    return 0;
  }
  public function contains(other: Node): Bool
  {
    if (this.isEqualNode(other))
      return true;
    var node = this.firstChild;
    while (node != null) {
      if (node.isEqualNode(other))
        return true;
      node = node.nextSibling;
    }
    return false;
  }

  public function insertBefore(node: Node, child: Node): Node {
    switch (this.nodeType) {
      case DOCUMENT_NODE
           | DOCUMENT_FRAGMENT_NODE
           | ELEMENT_NODE: {}
      case _: throw "Hierarchy request error";
    }

    if (child != null && child.parentNode != this)
      throw "Not found error";

    if (node == null)
      throw "Hierarchy request error";
    switch (node.nodeType) {
      case DOCUMENT_FRAGMENT_NODE
           | DOCUMENT_TYPE_NODE
           | ELEMENT_NODE
           | TEXT_NODE
           | PROCESSING_INSTRUCTION_NODE
           | COMMENT_NODE: {}
      case _: throw "Hierarchy request error";
    }

    if ((node.nodeType == TEXT_NODE && this.nodeType == DOCUMENT_NODE)
        || (node.nodeType == DOCUMENT_TYPE_NODE && this.nodeType != DOCUMENT_NODE))
      throw "Hierarchy request error";

    if (this.nodeType == DOCUMENT_NODE) {
      if (node.nodeType == DOCUMENT_FRAGMENT_NODE) {
        if (node.firstElementChild != null && node.firstElementChild != node.lastElementChild)
          throw "Hierarchy request error";
        var currentNode = node.firstChild;
        while (currentNode != null) {
          if (currentNode.nodeType == TEXT_NODE)
            throw "Hierarchy request error";
          currentNode = child.nextSibling;
        }

        if (node.firstElementChild != null
            && (this.firstElementChild != null
                || (child != null && child.nodeType == DOCUMENT_TYPE_NODE)
                || (child != null && child.nextSibling != null && child.nextSibling.nodeType == DOCUMENT_TYPE_NODE)))
          throw "Hierarchy request error";
      }
      else if (node.nodeType == ELEMENT_NODE) {
        if (this.firstElementChild != null
            || (child != null && child.nodeType == DOCUMENT_TYPE_NODE)
            || (child != null && child.nextSibling != null && child.nextSibling.nodeType == DOCUMENT_TYPE_NODE))
          throw "Hierarchy request error";
      }
      else if (node.nodeType == DOCUMENT_TYPE_NODE) {
        var currentNode = this.firstChild;
        var foundDoctypeInParent = false;
        while (!foundDoctypeInParent && child != null) {
          if (currentNode.nodeType == DOCUMENT_TYPE_NODE)
            foundDoctypeInParent = true;
          currentNode = currentNode.nextSibling;
        }
        if (foundDoctypeInParent
            || (child != null && child.previousElementSibling != null)
            || (child == null && this.firstElementChild != null))
          throw "Hierarchy request error";
      }
    }

   var referenceChild = child;
   if (referenceChild == node) {
     referenceChild = node.nextSibling;
   }

   if (referenceChild == null) {
     node.previousSibling = this.lastChild;
     if (this.lastChild != null) {
       this.lastChild.nextSibling = node;
     }
     this.lastChild = node;
   }
   else {
     node.previousSibling = referenceChild.previousSibling;
     node.nextSibling = referenceChild;
     referenceChild.previousSibling = node;
   }
   if (this.firstChild == referenceChild)
     this.firstChild = node;

    return node;
  }

  public function appendChild(node: Node): Node
  {
    return insertBefore(node, null);
  }

  public function removeChild(child: Node): Node
  {
    if (child == null || child.parentNode == null)
      throw "Hierarchy request error";

    if (child.parentNode != this)
      throw "Not found error";

    var parent = child.parentNode;
    if (child.previousSibling != null)
      child.previousSibling.nextSibling = child.nextSibling;
    if (child.nextSibling != null)
      child.nextSibling.previousSibling = child.previousSibling;
    if (parent.firstChild == child)
      parent.firstChild = child.nextSibling;
    if (parent.lastChild == child)
      parent.lastChild = null;

    Document._setNodeOwnerDocument(child, null);
    return child;
  }

  public function new() {
    super();
  }
}