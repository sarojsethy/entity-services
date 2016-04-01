(:
 Copyright 2002-2016 MarkLogic Corporation.  All Rights Reserved. 

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
:)
xquery version "1.0-ml";


module namespace es-codegen = "http://marklogic.com/entity-services-codegen";

import module namespace esi = "http://marklogic.com/entity-services-impl"
    at "entity-services-impl.xqy";

declare namespace es = "http://marklogic.com/entity-services";
declare namespace tde = "http://marklogic.com/xdmp/tde";


(:~
 : Generates an XQuery module that can be customized and used
 : to support transforms associated with an entity type
 : @param $entity-type  An entity type object.
 : @return An XQuery module (text) that can be edited and installed in a modules database.
 :)
declare function es-codegen:conversion-module-generate(
    $entity-type as map:map
) as document-node()
{
    let $default-base-uri := "http://example.org/"
    let $info := map:get($entity-type, "info")
    let $title := map:get($info, "title")
    let $prefix := lower-case(substring($title,1,1)) || substring($title,2)
    let $version:= map:get($info, "version")
    let $definitions := map:get($entity-type, "definitions")
    let $base-uri := fn:head((map:get($info, "baseUri"), $default-base-uri))
    let $base-uri := 
            if (fn:matches($base-uri, "[#/]$")) 
            then $base-uri 
            else concat($base-uri, "#")
    return
document {
<conversion-module>
xquery version "1.0-ml";

(: This module was generated by MarkLogic Entity Services. 
 : The source entity type document was {$title}-{$version}
 :
 : Modification History:
 :   Generated at timestamp: {fn:current-dateTime()}
 :   Persisted by AUTHOR
 :   Date: DATE
 :)
module namespace {$prefix} = "{$base-uri}{$title}-{$version}";

import module namespace es = "http://marklogic.com/entity-services" 
    at "/MarkLogic/entity-services/entity-services.xqy";

(: extract-instance-{{entity-type}} Functions :)
(: These functions can be customized to reflect a data source for an entity type :)
{ (: iterate over entity types to make extract instance stubs :)
    for $entity-type-key in map:keys(map:get($entity-type, "definitions"))
    return 
    <extract-instance>
declare function {$prefix}:extract-instance-{$entity-type-key}(
    $source-node as node()
) as map:map
{{
    let $instance := json:object()
    let $_ := map:put($instance, "$type", "{$entity-type-key}")
    let $_ := map:put($instance, "$attachments", $source-node)
    {
    let $this-type := map:get($definitions, $entity-type-key)
    let $properties-map := map:get($this-type, "properties")
    let $properties-keys := map:keys($properties-map)
    for $property-key in map:keys($properties-map)
    let $is-array := map:get(map:get($properties-map, $property-key), "datatype") eq "array"
    let $ref :=
        if ($is-array)
        then map:get(map:get(map:get($properties-map, $property-key), "items"), "$ref")
        else map:get(map:get($properties-map, $property-key), "$ref")
    let $path-to-property := concat("$source-node/", $entity-type-key, "/", $property-key)
    let $value := 
        if (empty($ref))
        then 
            concat($path-to-property, " ! data(.)")
        else 
            if(contains($ref, "#/definitions"))
            then
            concat("if (not(",
                    $path-to-property,
                    "/element())) &#10;then ",
                    "data(", $path-to-property, ")",
                    "&#10;else ",
                    $path-to-property,
                    " ! ",
                    $prefix,
                    ":extract-instance-",
                    replace($ref, "#/definitions/", ""),
                    "(.)"
                    )
            else
               concat($path-to-property, "/node()")
                
    return
    
    concat("let $_ := if (empty( (",
            $path-to-property,
            ")))&#10;",
            "         then () &#10;",
            "         else map:put($instance, '", $property-key, "', ",$value, ")&#10;   "
          )
    }
        return $instance
}};
    </extract-instance>/text()
}

(: instance-to-canonical-xml function
 : Depending on the relationships among your entity types
 : you may wish to modify sections of this function
 : to meet your own purposes.
 :)
declare function {$prefix}:instance-to-canonical-xml(
    $entity-instance as map:map
) as element(es:instance)
{{
    let $title := "{$title}"
    let $version := "{$version}"
    let $instance-keys := map:keys($entity-instance)
    let $instance-node :=
        (: Construct the instance wrapper element itself :)
        element es:instance {{
            (: Construct the metadata for the instance :)
            element es:info {{
                element es:title {{ $title }},
                element es:version {{ $version }}
                (: TODO id :)
            }},
            (: Construct an element that is named the same as the Entity Type :)
            element {{ map:get($entity-instance, "$type") }}  {{
                for $key in $instance-keys
                let $instance-property := map:get($entity-instance, $key)
                where ($key castable as xs:NCName and $key ne "$type")
                return
                    typeswitch ($instance-property)
                    (: This branch handles embedded objects.  You can choose to prune
                       an entity's representation of extend it with lookups here. :)
                    case json:object+ 
                        return
                            for $prop in $instance-property
                            return element {{ $key }} {{ {$prefix}:instance-to-canonical-xml($prop)/(*[exists(./*)] except es:info) }}
                    (: A sequence of values should be simply treated as multiple elements :)
                    case item()+
                        return 
                            for $val in $instance-property
                            return element {{ $key }} {{ $val }}
                    (: An array by convention can also treated as multiple elements :)
                    case json:array
                        return 
                            for $val in json:array-values($instance-property)
                            return element {{ $key }} {{ $val }}
                    default return element {{ $key }} {{ $instance-property }}
            }}
        }}
    return $instance-node
}};


(: instance-to-envelope 
 : This function is used to wrap sources and entity instances
 : within the same document
 :)
declare function {$prefix}:instance-to-envelope(
    $entity-instance as map:map
) as element(es:envelope)
{{
    element es:envelope {{
        {$prefix}:instance-to-canonical-xml($entity-instance),
        element es:attachments {{
            map:get($entity-instance, "$attachments") 
        }}
    }}
}};


(: instance-from-document 
 : if you have modified instance-to-envelope
 : you may need also to modify this function
 :)
declare function {$prefix}:instance-from-document(
    $document as document-node()
) as map:map*
{{
    let $xml-from-document := {$prefix}:instance-xml-from-document($document)
    for $root-instance in $xml-from-document
        let $instance := json:object()
        let $_ :=
            for $property in $root-instance/*
            return
                if ($property/element())
                then map:put($instance, local-name($property), $property/* ! {$prefix}:child-instance(.))
                else map:put($instance, local-name($property), data($property))
        return $instance
}};

declare function {$prefix}:child-instance(
    $element as element()
) as map:map*
{{
    let $child := json:object()
    let $_ := 
        for $property in $element/*
        return
            if ($property/element())
            then map:put($child, local-name($property), {$prefix}:child-instance($property))
            else map:put($child, local-name($property), data($property))
    return $child
}};


(:~
 : Returns all XML from within a document envelope except the es:info.
 : This function is generic enough not to require customization for
 : most entity type implementations.
 :)
declare function {$prefix}:instance-xml-from-document(
    $document as document-node()
) as element()
{{
    $document//es:instance/(* except es:info)
}};

declare function {$prefix}:instance-json-from-document(
    $document as document-node()
) as object-node()
{{
    let $instance := {$prefix}:instance-from-document($document)
    return xdmp:to-json($instance)/node()
}};


declare function {$prefix}:instance-get-attachments(
    $document as document-node()
) as element()*
{{
    $document//es:attachments/*
}};

</conversion-module>/text()
}


};
