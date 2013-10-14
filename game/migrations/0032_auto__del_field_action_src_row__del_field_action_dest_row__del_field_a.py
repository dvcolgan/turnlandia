# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Deleting field 'Action.src_row'
        db.delete_column(u'game_action', 'src_row')

        # Deleting field 'Action.dest_row'
        db.delete_column(u'game_action', 'dest_row')

        # Deleting field 'Action.src_col'
        db.delete_column(u'game_action', 'src_col')

        # Deleting field 'Action.dest_col'
        db.delete_column(u'game_action', 'dest_col')

        # Adding field 'Action.col'
        db.add_column(u'game_action', 'col',
                      self.gf('django.db.models.fields.IntegerField')(default=0),
                      keep_default=False)

        # Adding field 'Action.row'
        db.add_column(u'game_action', 'row',
                      self.gf('django.db.models.fields.IntegerField')(default=0),
                      keep_default=False)


    def backwards(self, orm):

        # User chose to not deal with backwards NULL issues for 'Action.src_row'
        raise RuntimeError("Cannot reverse this migration. 'Action.src_row' and its values cannot be restored.")
        
        # The following code is provided here to aid in writing a correct migration        # Adding field 'Action.src_row'
        db.add_column(u'game_action', 'src_row',
                      self.gf('django.db.models.fields.IntegerField')(),
                      keep_default=False)


        # User chose to not deal with backwards NULL issues for 'Action.dest_row'
        raise RuntimeError("Cannot reverse this migration. 'Action.dest_row' and its values cannot be restored.")
        
        # The following code is provided here to aid in writing a correct migration        # Adding field 'Action.dest_row'
        db.add_column(u'game_action', 'dest_row',
                      self.gf('django.db.models.fields.IntegerField')(),
                      keep_default=False)


        # User chose to not deal with backwards NULL issues for 'Action.src_col'
        raise RuntimeError("Cannot reverse this migration. 'Action.src_col' and its values cannot be restored.")
        
        # The following code is provided here to aid in writing a correct migration        # Adding field 'Action.src_col'
        db.add_column(u'game_action', 'src_col',
                      self.gf('django.db.models.fields.IntegerField')(),
                      keep_default=False)


        # User chose to not deal with backwards NULL issues for 'Action.dest_col'
        raise RuntimeError("Cannot reverse this migration. 'Action.dest_col' and its values cannot be restored.")
        
        # The following code is provided here to aid in writing a correct migration        # Adding field 'Action.dest_col'
        db.add_column(u'game_action', 'dest_col',
                      self.gf('django.db.models.fields.IntegerField')(),
                      keep_default=False)

        # Deleting field 'Action.col'
        db.delete_column(u'game_action', 'col')

        # Deleting field 'Action.row'
        db.delete_column(u'game_action', 'row')


    models = {
        u'auth.group': {
            'Meta': {'object_name': 'Group'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '80'}),
            'permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'})
        },
        u'auth.permission': {
            'Meta': {'ordering': "(u'content_type__app_label', u'content_type__model', u'codename')", 'unique_together': "((u'content_type', u'codename'),)", 'object_name': 'Permission'},
            'codename': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'content_type': ('django.db.models.fields.related.ForeignKey', [], {'to': u"orm['contenttypes.ContentType']"}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '50'})
        },
        u'contenttypes.contenttype': {
            'Meta': {'ordering': "('name',)", 'unique_together': "(('app_label', 'model'),)", 'object_name': 'ContentType', 'db_table': "'django_content_type'"},
            'app_label': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'model': ('django.db.models.fields.CharField', [], {'max_length': '100'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '100'})
        },
        u'game.account': {
            'Meta': {'object_name': 'Account'},
            'color': ('django.db.models.fields.CharField', [], {'max_length': '10', 'blank': 'True'}),
            'date_joined': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'email': ('django.db.models.fields.EmailField', [], {'max_length': '75', 'blank': 'True'}),
            'food': ('django.db.models.fields.PositiveIntegerField', [], {'default': '0'}),
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'leader_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'money': ('django.db.models.fields.PositiveIntegerField', [], {'default': '100'}),
            'ore': ('django.db.models.fields.PositiveIntegerField', [], {'default': '0'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'people_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'unplaced_units': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'}),
            'wood': ('django.db.models.fields.PositiveIntegerField', [], {'default': '0'})
        },
        u'game.action': {
            'Meta': {'object_name': 'Action'},
            'col': ('django.db.models.fields.IntegerField', [], {}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'kind': ('django.db.models.fields.CharField', [], {'max_length': '30'}),
            'player': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'actions'", 'to': u"orm['game.Account']"}),
            'row': ('django.db.models.fields.IntegerField', [], {}),
            'timestamp': ('django.db.models.fields.DateTimeField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            'turn': ('django.db.models.fields.IntegerField', [], {})
        },
        u'game.message': {
            'Meta': {'object_name': 'Message'},
            'body': ('django.db.models.fields.TextField', [], {}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'recipient': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'received_messages'", 'to': u"orm['game.Account']"}),
            'sender': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'sent_messages'", 'to': u"orm['game.Account']"}),
            'subject': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'time_sent': ('django.db.models.fields.DateTimeField', [], {'auto_now': 'True', 'blank': 'True'})
        },
        u'game.setting': {
            'Meta': {'object_name': 'Setting'},
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'value': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        u'game.square': {
            'Meta': {'object_name': 'Square'},
            'col': ('django.db.models.fields.IntegerField', [], {}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'north_east_tile_24': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'north_west_tile_24': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'resource_amount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'row': ('django.db.models.fields.IntegerField', [], {}),
            'south_east_tile_24': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'south_west_tile_24': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'terrain_type': ('django.db.models.fields.CharField', [], {'max_length': '20'}),
            'tile_48': ('django.db.models.fields.IntegerField', [], {'null': 'True', 'blank': 'True'}),
            'unit_amount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'unit_owner': ('django.db.models.fields.related.ForeignKey', [], {'blank': 'True', 'related_name': "'squares_with_units'", 'null': 'True', 'to': u"orm['game.Account']"})
        },
        u'game.trophy': {
            'Meta': {'object_name': 'Trophy'},
            'description': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_path': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'})
        },
        u'game.trophyawarding': {
            'Meta': {'object_name': 'TrophyAwarding'},
            'date_awarded': ('django.db.models.fields.DateField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'reasoning': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'recipient': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'awardings'", 'to': u"orm['game.Account']"}),
            'trophy': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'awardings'", 'to': u"orm['game.Trophy']"})
        }
    }

    complete_apps = ['game']