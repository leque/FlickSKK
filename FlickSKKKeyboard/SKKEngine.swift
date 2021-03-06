// SKKのメインエンジン

class SKKEngine {
    private let keyHandler : KeyHandler
    private weak var delegate : SKKDelegate?

    private var composeMode : ComposeMode = .DirectInput

    private let presenter = ComposeModePresenter()

    init(delegate : SKKDelegate, dictionary : SKKDictionary){
        self.delegate = delegate
        self.keyHandler = KeyHandler(delegate: delegate, dictionary: dictionary)
    }

    func currentComposeMode() -> ComposeMode {
        return self.composeMode
    }

    func handle(keyEvent : SKKKeyEvent) {
        // 状態遷移
        self.composeMode = keyHandler.handle(keyEvent, composeMode: composeMode)

        // 表示を更新
        self.delegate?.composeText(presenter.toString(self.composeMode))

        // 候補表示
        self.delegate?.showCandidates(candidates()?.candidates)
    }

    func candidates() -> (candidates: [Candidate], index: Int?)? {
        return self.presenter.candidates(self.composeMode)
    }

    func inStatusShowsCandidatesBySpace() -> Bool {
        return self.presenter.inStatusShowsCandidatesBySpace(composeMode)
    }

    var hasPartialCandidates: Bool {
        let cs = candidates()?.candidates ?? []
        return cs.any{$0.isPartial}
    }
}
