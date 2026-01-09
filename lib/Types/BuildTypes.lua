export type FlameBuildConfig = {
    --NetworkRoot: Folder?,
    EnableServerClientComms: boolean?,
    DoNotAnnounceRunner: boolean?,
}

export type ServerBuildProps = {
    ContextCommunicator: RemoteEvent?,
    DispatcherReceiver: RemoteFunction,
    DoNotAnnounceRunner: boolean?,
}
export type ClientBuildProps = {
    ContextCommunicator: RemoteEvent?,
    DispatcherReceiver: RemoteFunction,
    DoNotAnnounceRunner: boolean?,
}

export type Builder<P> = {
    __call: () -> Builder<P>,
    IS_BUILDING: boolean?,
    HAS_BUILT: boolean?,
    Props: P
}

return {}