<input type="text" id="{{$id}}" name="{{$name}}" size="{{$size}}" {{if $describedby}}aria-describedby="{{$describedby}}"{{/if}} />

<script type="text/javascript">
addLoadEvent(function () {
    $j("#{{$id}}").tokenInput('{{$ajax}}',
        {
            {{if $theme}}theme: "{{$theme}}",{{/if}}
            preventDuplicates: true,
            animateDropdown: false,
            minChars: 2,
            resultsLimit: 20,
            tokenValue: "id",
            propertyToSearch: "name",
            hintText: "{{$hint}}",
            allowFreeTagging: {{$allowadding}},
            noResultsText: "{{str tag='noresultsfound' section='mahara'}}",
            searchingText: "{{str tag='searching' section='mahara'}}",
            prePopulate: {{$value|clean_html|safe}},
        }
    );
});
</script>
