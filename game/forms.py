from django import forms
from game.models import *

class CreateAccountForm(forms.ModelForm):
    error_messages = {
        'username_taken': "That username is taken.",
        'password_mismatch': "Passwords do not match",
    }
    password1 = forms.CharField(label="Password", help_text='Make it real secure', widget=forms.PasswordInput)
    password2 = forms.CharField(label="Repeat password", help_text='Just in case', widget=forms.PasswordInput)

    class Meta:
        model = Account
        fields = ('username', 'email')

    def clean_password2(self):
        password1 = self.cleaned_data.get("password1")
        password2 = self.cleaned_data.get("password2")
        if password1 and password2 and password1 != password2:
            raise forms.ValidationError(
                self.error_messages['password_mismatch'])
        return password2

    def save(self, commit=True):
        account = super(CreateAccountForm, self).save(commit=False)
        account.set_password(self.cleaned_data["password1"])
        if commit:
            account.save()
        return account

class SettingsForm(forms.ModelForm):
    class Meta:
        model = Account
        fields = ('color', 'leader_name', 'people_name', 'country_name')


class SendMessageForm(forms.ModelForm):
    class Meta:
        model = Message
        fields = ('recipient', 'subject', 'body')
