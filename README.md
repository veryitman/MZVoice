
## MZVoice

**基于 GVoice 语音 SDK 实现的 Demo. 当时只有 C++版本的 GVoice，自己针对该版本封装给 OC 工程使用。**

1. `MZIMVoiceManager` 是针对腾讯 GVoice SDK 的 OC 封装。

2. 由于 `libGCloudVoice.a` 文件过大, github 不允许上传.需要你自己下载放到 `GVoice/libs` 目录。

3. `MZIMVoiceManager` 中的 `initIMVoiceSDK` 需要填写你自己申请的 appid 和 appkey.

4. 配置权限

详见工程 info.plist 文件。

5. 后台播放

详见工程 `AppDelegate.m` 文件。


