package Fastadb::Schema::Result::SubSeq;

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('subseq_view');

#
# ->add_columns, etc.
#

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
  SELECT SUBSTR(s.seq, (?+1), ?) as seq FROM seq s
  WHERE s.trunc512 = ?
]);

__PACKAGE__->add_columns(
  'seq' => {
    data_type => 'varchar',
	},
);

1;