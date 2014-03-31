<h4><img src={$icon} alt='Item'><a href={$WWWROOT}artefact/artefact.php?artefact={$id}>{$title}</a></h4>
<div>Type: {$type}</div>
<div>Author: <a href="{profile_url($owner)}">{$owner|display_name:null:true}</a></div>
{if $description} <div>Description: {$description|safe} </div>{/if}
