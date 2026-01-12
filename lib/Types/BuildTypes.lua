export type FlameBuildConfig = {
	DoNotAnnounceRunner: boolean?,
	EntryPoints: { Enum.KeyCode | BindableEvent },
}

export type ServerBuildProps = {
	ContextCommunicator: RemoteFunction,
	DispatcherReceiver: RemoteFunction,
	DoNotAnnounceRunner: boolean?,
}
export type ClientBuildProps = {
	ContextCommunicator: RemoteFunction,
	DispatcherReceiver: RemoteFunction,
	DoNotAnnounceRunner: boolean?,
	EntryPoints: { Enum.KeyCode | BindableEvent },
}

export type Builder<P> = {
	__call: () -> Builder<P>,
	IS_BUILDING: boolean?,
	HAS_BUILT: boolean?,
	Props: P,
}

return {}
