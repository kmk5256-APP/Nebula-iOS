import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var life: CGFloat
    var maxLife: CGFloat
    var colorIndex: Int
    var hueShift: CGFloat
}

struct ParticleCanvas: View {
    @EnvironmentObject var store: ArtStore
    @State private var particles: [Particle] = []
    @State private var time: Double = 0
    @State private var lastSize: CGSize = .zero
    @State private var seed: UInt64 = UInt64.random(in: 0...UInt64.max)
    
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1/60, paused: !store.isPlaying)) { timeline in
                Canvas { context, size in
                    // Background gradient based on palette
                    let bgGradient = Gradient(colors: [
                        store.currentPalette.colors[0].opacity(0.15),
                        Color.black,
                        store.currentPalette.colors[2].opacity(0.12)
                    ])
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .linearGradient(
                            bgGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Draw particles / forms based on mode
                    switch store.currentMode {
                    case .particles:
                        drawParticles(context: context, size: size)
                    case .flowField:
                        drawFlowField(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                    case .organic:
                        drawOrganic(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                    case .geometry:
                        drawGeometry(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                    case .aurora:
                        drawAurora(context: context, size: size, time: timeline.date.timeIntervalSinceReferenceDate)
                    }
                    
                    // Subtle vignette
                    let vignette = Gradient(colors: [
                        .clear,
                        .black.opacity(0.45)
                    ])
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .radialGradient(
                            vignette,
                            center: CGPoint(x: size.width/2, y: size.height/2),
                            startRadius: size.width * 0.3,
                            endRadius: size.width * 0.85
                        )
                    )
                }
                .onChange(of: timeline.date) { _, _ in
                    updateSimulation(size: geo.size)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        emitAt(point: value.location, size: geo.size)
                    }
            )
            .onTapGesture(count: 2) {
                burst(at: CGPoint(x: geo.size.width/2, y: geo.size.height/2), size: geo.size)
            }
            .onAppear {
                lastSize = geo.size
                seedParticles(size: geo.size)
            }
            .onChange(of: geo.size) { _, newSize in
                if newSize != lastSize {
                    lastSize = newSize
                    seedParticles(size: newSize)
                }
            }
            .onChange(of: store.currentMode) { _, _ in
                seedParticles(size: geo.size)
            }
            .onChange(of: store.currentPalette) { _, _ in
                // Keep particles, just recolor
            }
        }
    }
    
    // MARK: - Drawing
    
    private func drawParticles(context: GraphicsContext, size: CGSize) {
        for p in particles {
            let progress = 1 - (p.life / p.maxLife)
            let alpha = Double(p.life / p.maxLife) * store.intensity
            let color = store.currentPalette.colors[p.colorIndex % store.currentPalette.colors.count]
                .opacity(alpha)
            
            var ctx = context
            ctx.opacity = alpha
            
            let rect = CGRect(
                x: p.x - p.size/2,
                y: p.y - p.size/2,
                width: p.size,
                height: p.size
            )
            
            // Soft glow
            ctx.addFilter(.blur(radius: p.size * 0.6))
            ctx.fill(Path(ellipseIn: rect.insetBy(dx: -p.size*0.3, dy: -p.size*0.3)), with: .color(color.opacity(0.4)))
            
            ctx.addFilter(.blur(radius: 0))
            ctx.fill(Path(ellipseIn: rect), with: .color(color))
            
            // Core highlight
            let core = rect.insetBy(dx: p.size*0.3, dy: p.size*0.3)
            ctx.fill(Path(ellipseIn: core), with: .color(.white.opacity(0.6 * alpha)))
        }
    }
    
    private func drawFlowField(context: GraphicsContext, size: CGSize, time: Double) {
        let cols = Int(12 + store.complexity * 20)
        let rows = Int(18 + store.complexity * 25)
        let cellW = size.width / CGFloat(cols)
        let cellH = size.height / CGFloat(rows)
        
        for i in 0..<cols {
            for j in 0..<rows {
                let x = CGFloat(i) * cellW + cellW/2
                let y = CGFloat(j) * cellH + cellH/2
                
                let angle = noise(x: x * 0.008, y: y * 0.008, t: time * store.speed * 0.3) * .pi * 2
                let length = 8 + store.intensity * 18
                
                let endX = x + cos(angle) * length
                let endY = y + sin(angle) * length
                
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: endX, y: endY))
                
                let colorIdx = (i + j) % store.currentPalette.colors.count
                let color = store.currentPalette.colors[colorIdx].opacity(0.55 * store.intensity)
                
                context.stroke(path, with: .color(color), lineWidth: 1.5 + store.intensity)
            }
        }
        
        // Overlay particles moving on the field
        drawParticles(context: context, size: size)
    }
    
    private func drawOrganic(context: GraphicsContext, size: CGSize, time: Double) {
        let count = Int(6 + store.complexity * 10)
        
        for i in 0..<count {
            let baseX = size.width * (0.2 + CGFloat(i % 3) * 0.3)
            let baseY = size.height * (0.25 + CGFloat(i / 3) * 0.3)
            
            let t = time * store.speed * 0.4 + Double(i)
            let radius = 40 + store.intensity * 80 + sin(t) * 25
            
            var path = Path()
            let points = 8 + Int(store.complexity * 8)
            
            for p in 0..<points {
                let angle = (CGFloat(p) / CGFloat(points)) * .pi * 2
                let r = radius * (0.7 + 0.3 * sin(angle * 3 + CGFloat(t)))
                let x = baseX + cos(angle + CGFloat(t * 0.3)) * r
                let y = baseY + sin(angle + CGFloat(t * 0.3)) * r
                
                if p == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            
            let color = store.currentPalette.colors[i % store.currentPalette.colors.count]
            
            var ctx = context
            ctx.opacity = 0.35 * store.intensity
            ctx.addFilter(.blur(radius: 12))
            ctx.fill(path, with: .color(color))
            
            ctx.addFilter(.blur(radius: 0))
            ctx.opacity = 0.6 * store.intensity
            ctx.stroke(path, with: .color(color.opacity(0.9)), lineWidth: 2)
        }
    }
    
    private func drawGeometry(context: GraphicsContext, size: CGSize, time: Double) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let maxR = min(size.width, size.height) * 0.42
        
        for ring in 0..<Int(3 + store.complexity * 5) {
            let r = maxR * (CGFloat(ring + 1) / 8)
            let sides = 5 + ring * 2
            let rotation = time * store.speed * 0.15 * Double(ring % 2 == 0 ? 1 : -1)
            
            var path = Path()
            for i in 0..<sides {
                let angle = (CGFloat(i) / CGFloat(sides)) * .pi * 2 + CGFloat(rotation)
                let x = center.x + cos(angle) * r
                let y = center.y + sin(angle) * r
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
            
            let color = store.currentPalette.colors[ring % store.currentPalette.colors.count]
            context.stroke(path, with: .color(color.opacity(0.7 * store.intensity)), lineWidth: 1.5)
            
            // Connecting lines to center
            if ring % 2 == 0 {
                for i in 0..<sides {
                    let angle = (CGFloat(i) / CGFloat(sides)) * .pi * 2 + CGFloat(rotation)
                    var line = Path()
                    line.move(to: center)
                    line.addLine(to: CGPoint(
                        x: center.x + cos(angle) * r,
                        y: center.y + sin(angle) * r
                    ))
                    context.stroke(line, with: .color(color.opacity(0.25)), lineWidth: 0.8)
                }
            }
        }
        
        // Floating crystals
        drawParticles(context: context, size: size)
    }
    
    private func drawAurora(context: GraphicsContext, size: CGSize, time: Double) {
        let bands = Int(4 + store.complexity * 6)
        
        for b in 0..<bands {
            var path = Path()
            let yBase = size.height * (0.15 + CGFloat(b) * 0.12)
            let amplitude = 30 + store.intensity * 50
            
            path.move(to: CGPoint(x: 0, y: yBase))
            
            for x in stride(from: 0, through: size.width, by: 4) {
                let t = time * store.speed * 0.5 + Double(b) * 0.7
                let y = yBase + sin(x * 0.01 + t) * amplitude * sin(x * 0.005 + t * 0.5)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Fill downward a bit for ribbon effect
            path.addLine(to: CGPoint(x: size.width, y: yBase + 40))
            path.addLine(to: CGPoint(x: 0, y: yBase + 40))
            path.closeSubpath()
            
            let color = store.currentPalette.colors[b % store.currentPalette.colors.count]
            
            var ctx = context
            ctx.opacity = 0.45 * store.intensity
            ctx.addFilter(.blur(radius: 8))
            ctx.fill(path, with: .color(color))
            
            ctx.addFilter(.blur(radius: 0))
            ctx.opacity = 0.7
            ctx.stroke(path, with: .color(color.opacity(0.9)), lineWidth: 1.5)
        }
        
        // Stars / particles
        drawParticles(context: context, size: size)
    }
    
    // MARK: - Simulation
    
    private func updateSimulation(size: CGSize) {
        guard store.isPlaying else { return }
        
        let dt: CGFloat = 1.0 / 60.0
        var newParticles: [Particle] = []
        
        for var p in particles {
            p.life -= dt * (0.3 + store.speed)
            
            // Mode-specific movement
            switch store.currentMode {
            case .particles, .geometry, .aurora:
                p.vx *= 0.99
                p.vy *= 0.99
                p.vy += 0.02 // slight gravity feel
            case .flowField:
                let angle = noise(x: p.x * 0.008, y: p.y * 0.008, t: time * store.speed * 0.3) * .pi * 2
                p.vx = cos(angle) * (1.5 + store.speed * 2)
                p.vy = sin(angle) * (1.5 + store.speed * 2)
            case .organic:
                p.vx += sin(p.y * 0.02 + time) * 0.1
                p.vy += cos(p.x * 0.02 + time) * 0.1
                p.vx *= 0.97
                p.vy *= 0.97
            }
            
            p.x += p.vx
            p.y += p.vy
            
            // Soft wrap
            if p.x < -20 { p.x = size.width + 20 }
            if p.x > size.width + 20 { p.x = -20 }
            if p.y < -20 { p.y = size.height + 20 }
            if p.y > size.height + 20 { p.y = -20 }
            
            if p.life > 0 {
                newParticles.append(p)
            }
        }
        
        // Maintain density
        let target = Int(store.particleCount * (0.5 + store.complexity * 0.5))
        while newParticles.count < target {
            newParticles.append(randomParticle(in: size))
        }
        
        particles = newParticles
        time += 0.016
    }
    
    private func seedParticles(size: CGSize) {
        particles = (0..<Int(store.particleCount)).map { _ in
            randomParticle(in: size)
        }
    }
    
    private func randomParticle(in size: CGSize) -> Particle {
        let life = CGFloat.random(in: 2...8)
        return Particle(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height),
            vx: CGFloat.random(in: -1.5...1.5),
            vy: CGFloat.random(in: -1.5...1.5),
            size: CGFloat.random(in: 2...(6 + store.intensity * 10)),
            life: life,
            maxLife: life,
            colorIndex: Int.random(in: 0..<store.currentPalette.colors.count),
            hueShift: CGFloat.random(in: 0...1)
        )
    }
    
    private func emitAt(point: CGPoint, size: CGSize) {
        for _ in 0..<Int(3 + store.intensity * 8) {
            let life = CGFloat.random(in: 1.5...4)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 1...4) * store.speed
            particles.append(Particle(
                x: point.x,
                y: point.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                size: CGFloat.random(in: 3...12),
                life: life,
                maxLife: life,
                colorIndex: Int.random(in: 0..<store.currentPalette.colors.count),
                hueShift: 0
            ))
        }
    }
    
    private func burst(at point: CGPoint, size: CGSize) {
        for _ in 0..<Int(40 + store.intensity * 60) {
            let life = CGFloat.random(in: 1...3.5)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 2...9)
            particles.append(Particle(
                x: point.x,
                y: point.y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                size: CGFloat.random(in: 2...9),
                life: life,
                maxLife: life,
                colorIndex: Int.random(in: 0..<store.currentPalette.colors.count),
                hueShift: 0
            ))
        }
    }
    
    // Simple value noise
    private func noise(x: CGFloat, y: CGFloat, t: Double) -> CGFloat {
        let n = sin(x * 12.9898 + y * 78.233 + t * 4.1414) * 43758.5453
        return CGFloat(n - floor(n))
    }
}
