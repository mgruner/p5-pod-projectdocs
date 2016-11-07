package Pod::ProjectDocs::IndexPage;

use strict;
use warnings;

use base qw/Pod::ProjectDocs::File/;
use Pod::ProjectDocs::Template;

__PACKAGE__->default_name('index.html');
__PACKAGE__->data( do{ local $/; <DATA> } );

__PACKAGE__->mk_accessors(qw/json components/);

sub _init {
    my($self, %args) = @_;
    $self->SUPER::_init(%args);
    $self->json( $args{json} );
    $self->components( $args{components} );
}

sub _get_data {
    my $self = shift;
    my $params = {
        title    => $self->config->title,
        desc     => $self->config->desc,
        lang     => $self->config->lang,
        json     => $self->json,
        css      => $self->components->{css}->tag($self),
        charset  => $self->config->charset || 'UTF-8',
    };
    my $tt = Pod::ProjectDocs::Template->new;
    my $text = $tt->process($self, $self->data, $params);
    return $text;
}

1;
__DATA__
<?xml version="1.0" encoding="[% charset %]"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="[% lang %]">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=[% charset %]" />
<title>[% title | html %]</title>
[% css %]
<script type="text/javascript">
//<![CDATA[
var managers = [% json %];
function render(pattern) {
    var html = '';
    for ( var i = 0; i < managers.length; i++ ) {
        var manager   = managers[i];
        var rows_html = get_rows_html(manager, pattern);
        var listbox = "<div class='box'><h2 class='t2'>"
                    + manager.desc
                    + "</h2><table width='100%'>"
                    + rows_html
                    + "</table></div>";
        html += listbox;
    }
    var list = document.getElementById('list');
    list.innerHTML = html;
}
function get_rows_html (manager, pattern) {
    var html   = '';
    var regexp = new RegExp( "(" + pattern + ")", "gi");
    var seq    = 0;
    for (var i = 0; i < manager.records.length; i++) {
        var record = manager.records[i];
        if ( record.name.match(regexp) ) {
            var module_name = manager.records[i].name;
            if(pattern != '' ) {
                var replace_text = "<span class='search_highlight'>$1</span>";
                module_name = module_name.replace(regexp, replace_text);
            }
            html += get_record_html(record, module_name, seq);
            seq++;
        }
    }
    return html;
}
function get_record_html (record, name, i) {
    var row_class  = ( i % 2 == 0 ) ? 'r' : 's';
    var row_html   = "<tr class='"
                   + row_class
                   + "'><td nowrap='nowrap'><a href='"
                   + record.path
                   + "'>"
                   + name + "</a></td><td width='99%'><small>"
                   + record.title
                   + "</small></td></tr>";
    return row_html;
}
//]]>
</script>
</head>
<body onload="render('')">
<div class="box">
  <h1 class="t1">[% title | html %]</h1>
  <table>
    <tr>
      <td class="label">Description</td>
      <td class="cell">[% desc | html_line_break %]</td>
    </tr>
  </table>
</div>

<div class="box">
  <h2 class="t2">Search</h2>
  <table>
    <tr>
       <td class="cell"><input type="text" size="60" onkeyup="render(this.value)" /></td>
    </tr>
  </table>
</div>

<div id="list">
</div>

[% FOREACH manager IN managers %]
[% IF manager.docs.size %]
<div class="box">
<h2 class="t2">[% manager.desc | html %]</h2>
  <table width="100%">
    [% seq = 1 %]
    [% FOREACH doc IN manager.docs %]
    <tr class="[% IF seq mod 2 == 1 %]r[% ELSE %]s[% END %]">
      <td nowrap="nowrap">
        <a href="[% doc.relpath %]">[% doc.name | html %]</a>
      </td>
      <td width="99%">
        <small>[% doc.title | html %]</small>
      </td>
    </tr>
    [% seq = seq + 1 %]
    [% END %]
  </table>
</div>
[% END %]
[% END %]
<div class="footer">generated by <a href="http://search.cpan.org/perldoc?Pod%3A%3AProjectDocs">Pod::ProjectDocs</a></div>
</body>
</html>
