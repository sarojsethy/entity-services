xquery version "1.0-ml";

(: 
 : This module was generated by MarkLogic Entity Services. 
 : The source entity type document was Race-0.0.1
 :
 : To use this module, examine how you wish to extract data from sources,
 : and modify the various extract-instance-{X} functions to 
 : create the instances you wish.
 :
 : You may wish to/need to alter
 : 1.  values.  For example, creating duration values from decimal months.
 : 2.  references.  This conversion module assumes you want to denormalize 
 :     instances when storing them in documents.  You may choose to remove 
 :     code that denormalizes, and just include reference values in your instances 
 :     instead.
 : 3.  Source XPath expressions.  The data coming into the extract-instance={X} 
 :     functions will probably not be exactly what this module predicts.
 :
 : After modifying this file, put it in your project for deployment to the modules 
 : database of your application, and check it into your source control system.
 :
 : Modification History:
 :   Generated at timestamp: 2016-04-22T10:24:14.942526-07:00
 :   Persisted by AUTHOR
 :   Date: DATE
 :)
module namespace race = "http://grechaw.github.io/entity-types#Race-0.0.1";

import module namespace es = "http://marklogic.com/entity-services" 
    at "/MarkLogic/entity-services/entity-services.xqy";


(:
 :  extract-instance-{entity-type} functions 
 :
 :  These functions take together take a source document and create a nested
 :  map structure from it.
 :  The resulting map is used by instance-to-canonical-xml to create documents
 :  in the database.
 :  
 :  There are numerous customizations you may wish to apply to this module.
 :)

(:~
 : Creates a map:map representation of an entity instance from some source
 : document.
 : @param $source-node  A document or node that contains data for populating a Race
 : @return A map:map instance that holds the data for this entity type.
 :)
declare function race:extract-instance-Race(
    $source-node as node()
) as map:map
{
    json:object()
        (: This line identifies the type of this instance.  Do not change it. :)
        =>es:with(true(), '$type', 'Race')
        (: This line adds the original source document as an attachment.
         : If this entity type is not the root of a document, you should remove this.
         : If the source document is JSON, you should wrap the $source-node in xdmp:quote()
         : because you cannot preserve JSON nodes with the XML envelope verbatim.
         :)
        =>es:with(true(), '$attachments', $source-node)
        (: The following lines are generated from the Race entity type 
         : You need to ensure that all of the property paths are correct for your source
         : data to populate instances.  You can also implement lookup functions, or 
         : populate the instance with constants.
         :)
        =>es:with($source-node/Race/name,             'name',                   data($source-node/Race/name))
        =>es:with($source-node/Race/comprisedOfRuns,  'comprisedOfRuns',                
            if ($source-node/Race/comprisedOfRuns/element())
            then json:to-array($source-node/Race/comprisedOfRuns ! race:extract-instance-Run(.))
            else data($source-node/Race/comprisedOfRuns))
        =>es:with($source-node/Race/wonByRunner,      'wonByRunner',                
            if ($source-node/Race/wonByRunner/element())
            then json:to-array($source-node/Race/wonByRunner ! race:extract-instance-Runner(.))
            else data($source-node/Race/wonByRunner))
        =>es:with($source-node/Race/courseLength,     'courseLength',                data($source-node/Race/courseLength))
   
};
    
(:~
 : Creates a map:map representation of an entity instance from some source
 : document.
 : @param $source-node  A document or node that contains data for populating a Run
 : @return A map:map instance that holds the data for this entity type.
 :)
declare function race:extract-instance-Run(
    $source-node as node()
) as map:map
{
    json:object()
        (: This line identifies the type of this instance.  Do not change it. :)
        =>es:with(true(), '$type', 'Run')
        (: This line adds the original source document as an attachment.
         : If this entity type is not the root of a document, you should remove this.
         : If the source document is JSON, you should wrap the $source-node in xdmp:quote()
         : because you cannot preserve JSON nodes with the XML envelope verbatim.
         :)
        =>es:with(true(), '$attachments', $source-node)
        (: The following lines are generated from the Run entity type 
         : You need to ensure that all of the property paths are correct for your source
         : data to populate instances.  You can also implement lookup functions, or 
         : populate the instance with constants.
         :)
        =>es:with($source-node/Run/id,                'id',                     data($source-node/Run/id))
        =>es:with($source-node/Run/date,              'date',                   data($source-node/Run/date))
        =>es:with($source-node/Run/distance,          'distance',               data($source-node/Run/distance))
        =>es:with($source-node/Run/distanceLabel,     'distanceLabel',               data($source-node/Run/distanceLabel))
        =>es:with($source-node/Run/duration,          'duration',               data($source-node/Run/duration))
        =>es:with($source-node/Run/runByRunner,       'runByRunner',               
            if ($source-node/Run/runByRunner/element())
            then json:to-array($source-node/Run/runByRunner ! race:extract-instance-Runner(.))
            else data($source-node/Run/runByRunner))
   
};
    
(:~
 : Creates a map:map representation of an entity instance from some source
 : document.
 : @param $source-node  A document or node that contains data for populating a Runner
 : @return A map:map instance that holds the data for this entity type.
 :)
declare function race:extract-instance-Runner(
    $source-node as node()
) as map:map
{
    json:object()
        (: This line identifies the type of this instance.  Do not change it. :)
        =>es:with(true(), '$type', 'Runner')
        (: This line adds the original source document as an attachment.
         : If this entity type is not the root of a document, you should remove this.
         : If the source document is JSON, you should wrap the $source-node in xdmp:quote()
         : because you cannot preserve JSON nodes with the XML envelope verbatim.
         :)
        =>es:with(true(), '$attachments', $source-node)
        (: The following lines are generated from the Runner entity type 
         : You need to ensure that all of the property paths are correct for your source
         : data to populate instances.  You can also implement lookup functions, or 
         : populate the instance with constants.
         :)
        =>es:with($source-node/Runner/name,           'name',                   data($source-node/Runner/name))
        =>es:with($source-node/Runner/age,            'age',                    data($source-node/Runner/age))
        =>es:with($source-node/Runner/gender,         'gender',                  data($source-node/Runner/gender))
   
};
    

(:~
 : Turns an entity instance into an XML structure.
 : This out-of-the box implementation traverses a map structure
 : and turns it deterministically into an XML tree.
 : Using this function as-is should be sufficient for most use
 : cases, and will play well with other generated artifacts.
 : @param $entity-instance A map:map instance returned from one of the extract-instance
 :    functions.
 : @return An XML element that encodes the instance.
 :)
declare function race:instance-to-canonical-xml(
    $entity-instance as map:map
) as element()
{
    (: Construct an element that is named the same as the Entity Type :)
    element { map:get($entity-instance, "$type") }  {
        for $key in map:keys($entity-instance)
        let $instance-property := map:get($entity-instance, $key)
        where ($key castable as xs:NCName and $key ne "$type")
        return
            typeswitch ($instance-property)
            (: This branch handles embedded objects.  You can choose to prune
               an entity's representation of extend it with lookups here. :)
            case json:object+ 
                return
                    for $prop in $instance-property
                    return element { $key } { race:instance-to-canonical-xml($prop) }
            (: An array can also treated as multiple elements :)
            case json:array
                return 
                    for $val in json:array-values($instance-property)
                    return
                        if ($val instance of json:object)
                        then element { $key } { race:instance-to-canonical-xml($val) }
                        else element { $key } { $val }
            (: A sequence of values should be simply treated as multiple elements :)
            case item()+
                return 
                    for $val in $instance-property
                    return element { $key } { $val }
            default return element { $key } { $instance-property }
    }
};


(: 
 : Wraps a canonical instance (returned by instance-to-canonical-xml())
 : within an envelope patterned document, along with the source
 : document, which is stored in an attachments section.
 : @param $entity-instance an instance, as returned by an extract-instance
 : function
 : @return A document which wraps both the canonical instance and source docs.
 :)
declare function race:instance-to-envelope(
    $entity-instance as map:map
) as document-node()
{
    document {
        element es:envelope {
            element es:instance {
                element es:info {
                    element es:title { "Race" },
                    element es:version { "0.0.1" }
                },
                race:instance-to-canonical-xml($entity-instance)
            },
            element es:attachments {
                map:get($entity-instance, "$attachments") 
            }
        }
    }
};

