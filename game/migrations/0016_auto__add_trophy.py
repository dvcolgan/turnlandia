# -*- coding: utf-8 -*-
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models


class Migration(SchemaMigration):

    def forwards(self, orm):
        # Adding model 'Trophy'
        db.create_table(u'game_trophy', (
            (u'id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('image_path', self.gf('django.db.models.fields.CharField')(max_length=255)),
            ('date_awarded', self.gf('django.db.models.fields.DateField')(auto_now_add=True, blank=True)),
        ))
        db.send_create_signal(u'game', ['Trophy'])

        # Adding M2M table for field owner on 'Trophy'
        m2m_table_name = db.shorten_name(u'game_trophy_owner')
        db.create_table(m2m_table_name, (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('trophy', models.ForeignKey(orm[u'game.trophy'], null=False)),
            ('account', models.ForeignKey(orm[u'game.account'], null=False))
        ))
        db.create_unique(m2m_table_name, ['trophy_id', 'account_id'])


    def backwards(self, orm):
        # Deleting model 'Trophy'
        db.delete_table(u'game_trophy')

        # Removing M2M table for field owner on 'Trophy'
        db.delete_table(db.shorten_name(u'game_trophy_owner'))


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
            'groups': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Group']", 'symmetrical': 'False', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'is_active': ('django.db.models.fields.BooleanField', [], {'default': 'True'}),
            'is_staff': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'is_superuser': ('django.db.models.fields.BooleanField', [], {'default': 'False'}),
            'last_login': ('django.db.models.fields.DateTimeField', [], {'default': 'datetime.datetime.now'}),
            'leader_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'password': ('django.db.models.fields.CharField', [], {'max_length': '128'}),
            'people_name': ('django.db.models.fields.CharField', [], {'max_length': '255', 'blank': 'True'}),
            'unplaced_units': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'user_permissions': ('django.db.models.fields.related.ManyToManyField', [], {'to': u"orm['auth.Permission']", 'symmetrical': 'False', 'blank': 'True'}),
            'username': ('django.db.models.fields.CharField', [], {'unique': 'True', 'max_length': '255'})
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
            'owner': ('django.db.models.fields.related.ForeignKey', [], {'blank': 'True', 'related_name': "'squares_owned'", 'null': 'True', 'to': u"orm['game.Account']"}),
            'resource_amount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'row': ('django.db.models.fields.IntegerField', [], {}),
            'wall_health': ('django.db.models.fields.IntegerField', [], {'default': '0'})
        },
        u'game.trophy': {
            'Meta': {'object_name': 'Trophy'},
            'date_awarded': ('django.db.models.fields.DateField', [], {'auto_now_add': 'True', 'blank': 'True'}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'image_path': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '255'}),
            'owner': ('django.db.models.fields.related.ManyToManyField', [], {'related_name': "'trophies'", 'symmetrical': 'False', 'to': u"orm['game.Account']"})
        },
        u'game.unit': {
            'Meta': {'object_name': 'Unit'},
            'amount': ('django.db.models.fields.IntegerField', [], {}),
            u'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'last_turn_amount': ('django.db.models.fields.IntegerField', [], {'default': '0'}),
            'owner': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'units'", 'to': u"orm['game.Account']"}),
            'square': ('django.db.models.fields.related.ForeignKey', [], {'related_name': "'units'", 'to': u"orm['game.Square']"})
        }
    }

    complete_apps = ['game']