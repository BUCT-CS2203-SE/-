import ExtensionAbility from '@ohos.app.ability.ExtensionAbility';
import hilog from '@ohos.hilog';
import Want from '@ohos.app.ability.Want';

export default class EntryBackupAbility extends ExtensionAbility {
  onCreate(want: Want): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'BackupExtensionAbility onCreate, want: ' + want.abilityName);
  }
}