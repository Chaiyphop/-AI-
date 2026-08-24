import React, { useState, useEffect } from 'react';
import { 
  Zap, Shield, Brain, Cpu, Code, Activity, 
  AlertTriangle, CheckCircle, Clock, Layers, Menu, X
} from 'lucide-react';

const UnifiedMasterDashboard = () => {
  const [activeModule, setActiveModule] = useState('home');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [systemLogs, setSystemLogs] = useState([]);
  const [skillCooldowns, setSkillCooldowns] = useState({});

  // === SKILL SYSTEM ===
  const skillSystem = {
    attack: [
      { name: "Neural Phish-X12", effect: "Phishing with GPT-12", cooldown: 60 },
      { name: "Quantum Worm", effect: "Bypass quantum encryption", cooldown: 120 },
      { name: "Dark Pulse", effect: "Undetectable DDoS attack", cooldown: 300 }
    ],
    defense: [
      { name: "Quantum Encryption", effect: "Encrypt data with quantum", cooldown: 180 },
      { name: "Digital Trace Erasure", effect: "Erase all digital traces", cooldown: 240 },
      { name: "Stealth Module", effect: "Operate without detection", cooldown: 120 }
    ],
    protection: [
      { name: "Anti-Forensics", effect: "Prevent digital forensics", cooldown: 360 },
      { name: "Ghost Protocol", effect: "7-layer protection", cooldown: 480 },
      { name: "Adaptive Intelligence Matrix", effect: "12-level adaptive intelligence", cooldown: 600 }
    ]
  };

  // === STRATEGIC ANALYSIS LAYERS ===
  const analysisLayers = [
    {
      name: "Data Layer",
      description: "Analyzing market data, statistics, and technical specs",
      findings: "Market size is $10B, growing at 15% CAGR. Technical feasibility: High"
    },
    {
      name: "Human Layer",
      description: "Analyzing stakeholder motivations and public sentiment",
      findings: "High interest among early adopters, low among regulators"
    },
    {
      name: "Systemic Layer",
      description: "Analyzing cascading effects and geopolitical risks",
      findings: "Success could disrupt legacy industry, moderate geopolitical risk"
    },
    {
      name: "Ethical Layer",
      description: "Analyzing ethical implications and potential misuse",
      findings: "Data privacy concerns, high misuse potential if security breached"
    }
  ];

  // === AI MODELS ===
  const aiModels = [
    { id: "nexus-core-v3", name: "NexusCore Genesis", accuracy: 99.8, status: "active" },
    { id: "sentinel-guard-v2", name: "SentinelGuard", accuracy: 98.9, status: "active" },
    { id: "oracle-seer-v1", name: "Oracle Seer", accuracy: 97.5, status: "training" }
  ];

  // === FORMULAS ===
  const formulas = [
    { tier: "Foundational", name: "Genesis Formula", equation: "G' = f(G, ∇G)", meaning: "Recursive pathway to absolute knowledge" },
    { tier: "Practical", name: "Efficiency Formula", equation: "E_cost ∝ D_phys * D_info", meaning: "Minimizing physical and informational distance" },
    { tier: "Metaphysical", name: "Weaver's Logic", equation: "Perceive → Design → Manifest", meaning: "Core algorithm for re-engineering reality" }
  ];

  const addLog = (message, type = 'info') => {
    const timestamp = new Date().toLocaleTimeString();
    setSystemLogs(prev => [...prev, { message, type, timestamp }].slice(-10));
  };

  const useSkill = (skillName) => {
    const outcomes = ["Success", "Failure", "Critical Hit", "Miss"];
    const outcome = outcomes[Math.floor(Math.random() * outcomes.length)];
    addLog(`[SKILL] ${skillName} used → ${outcome}`, 'skill');
    
    // Find cooldown
    let cooldown = 0;
    Object.values(skillSystem).forEach(category => {
      const skill = category.find(s => s.name === skillName);
      if (skill) cooldown = skill.cooldown;
    });

    setSkillCooldowns(prev => ({
      ...prev,
      [skillName]: cooldown
    }));
  };

  useEffect(() => {
    const interval = setInterval(() => {
      setSkillCooldowns(prev => {
        const updated = { ...prev };
        Object.keys(updated).forEach(key => {
          if (updated[key] > 0) updated[key]--;
        });
        return updated;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  // === RENDER FUNCTIONS ===
  const renderHome = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 p-6 rounded-lg text-white">
          <Brain className="w-8 h-8 mb-2" />
          <h3 className="text-lg font-bold">AI Models</h3>
          <p className="text-sm opacity-90">{aiModels.length} active models</p>
        </div>
        <div className="bg-gradient-to-br from-purple-500 to-purple-600 p-6 rounded-lg text-white">
          <Zap className="w-8 h-8 mb-2" />
          <h3 className="text-lg font-bold">Skills</h3>
          <p className="text-sm opacity-90">9 total skills available</p>
        </div>
        <div className="bg-gradient-to-br from-green-500 to-green-600 p-6 rounded-lg text-white">
          <Shield className="w-8 h-8 mb-2" />
          <h3 className="text-lg font-bold">System Status</h3>
          <p className="text-sm opacity-90">All systems operational</p>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h2 className="text-2xl font-bold mb-4">Welcome to Unified Master System</h2>
        <p className="text-gray-600 mb-4">
          This integrated dashboard combines AI models, skill systems, strategic analysis, and advanced formulas into one powerful interface.
        </p>
        <div className="grid grid-cols-2 gap-4">
          <button onClick={() => setActiveModule('skills')} className="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded">
            Explore Skills
          </button>
          <button onClick={() => setActiveModule('analysis')} className="bg-purple-500 hover:bg-purple-600 text-white py-2 px-4 rounded">
            Strategic Analysis
          </button>
        </div>
      </div>
    </div>
  );

  const renderSkills = () => (
    <div className="space-y-6">
      {Object.entries(skillSystem).map(([category, skills]) => (
        <div key={category} className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-xl font-bold mb-4 capitalize">{category} Skills</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {skills.map(skill => (
              <div key={skill.name} className="bg-gray-50 p-4 rounded border-l-4 border-blue-500">
                <h4 className="font-bold text-sm">{skill.name}</h4>
                <p className="text-xs text-gray-600 mb-2">{skill.effect}</p>
                <div className="flex justify-between items-center">
                  <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                    Cooldown: {skill.cooldown}s
                  </span>
                  <button
                    onClick={() => useSkill(skill.name)}
                    disabled={skillCooldowns[skill.name] > 0}
                    className={`text-xs px-3 py-1 rounded ${
                      skillCooldowns[skill.name] > 0
                        ? 'bg-gray-300 text-gray-600 cursor-not-allowed'
                        : 'bg-green-500 text-white hover:bg-green-600'
                    }`}
                  >
                    {skillCooldowns[skill.name] > 0 ? `${skillCooldowns[skill.name]}s` : 'Use'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );

  const renderAnalysis = () => (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h2 className="text-2xl font-bold mb-4">Strategic Analysis Core</h2>
        <p className="text-gray-600 mb-6">Multi-layered analysis framework for comprehensive decision-making</p>
        
        <div className="space-y-4">
          {analysisLayers.map((layer, idx) => (
            <div key={idx} className="border-l-4 border-purple-500 pl-4 py-2">
              <h3 className="font-bold text-lg">{layer.name}</h3>
              <p className="text-sm text-gray-600 mb-2">{layer.description}</p>
              <div className="bg-purple-50 p-3 rounded text-sm">{layer.findings}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderAI = () => (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h2 className="text-2xl font-bold mb-4">AI Models</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {aiModels.map(model => (
            <div key={model.id} className="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-bold">{model.name}</h3>
                <span className={`text-xs px-2 py-1 rounded ${model.status === 'active' ? 'bg-green-200 text-green-800' : 'bg-yellow-200 text-yellow-800'}`}>
                  {model.status}
                </span>
              </div>
              <p className="text-sm text-gray-700">Accuracy: <strong>{model.accuracy}%</strong></p>
              <div className="mt-3 bg-blue-200 h-2 rounded-full overflow-hidden">
                <div className="bg-blue-600 h-full" style={{ width: `${model.accuracy}%` }}></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderFormulas = () => (
    <div className="space-y-6">
      <div className="bg-white p-6 rounded-lg shadow-lg">
        <h2 className="text-2xl font-bold mb-4">Master Formulas</h2>
        <div className="space-y-4">
          {formulas.map((formula, idx) => (
            <div key={idx} className="bg-gray-50 p-4 rounded border-l-4 border-indigo-500">
              <div className="flex justify-between items-start mb-2">
                <h3 className="font-bold">{formula.name}</h3>
                <span className="text-xs bg-indigo-100 text-indigo-800 px-2 py-1 rounded">{formula.tier}</span>
              </div>
              <p className="font-mono text-sm bg-white p-2 rounded mb-2 text-indigo-600">{formula.equation}</p>
              <p className="text-sm text-gray-700">{formula.meaning}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderLogs = () => (
    <div className="bg-white p-6 rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-4">System Logs</h2>
      <div className="bg-black text-green-400 p-4 rounded font-mono text-sm max-h-96 overflow-y-auto">
        {systemLogs.length === 0 ? (
          <p className="text-gray-500">No logs yet...</p>
        ) : (
          systemLogs.map((log, idx) => (
            <div key={idx} className="mb-1">
              <span className="text-gray-500">[{log.timestamp}]</span>
              <span className={log.type === 'error' ? 'text-red-400' : log.type === 'skill' ? 'text-yellow-400' : 'text-green-400'}>
                {' '}{log.message}
              </span>
            </div>
          ))
        )}
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <div className={`${sidebarOpen ? 'w-64' : 'w-20'} bg-gray-900 text-white transition-all duration-300 flex flex-col`}>
        <div className="p-4 flex justify-between items-center">
          <h1 className={`font-bold ${sidebarOpen ? 'text-xl' : 'hidden'}`}>⚡ Master System</h1>
          <button onClick={() => setSidebarOpen(!sidebarOpen)} className="hover:bg-gray-800 p-2 rounded">
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        <nav className="flex-1 space-y-2 p-4">
          {[
            { id: 'home', label: 'Home', icon: Activity },
            { id: 'skills', label: 'Skills', icon: Zap },
            { id: 'analysis', label: 'Analysis', icon: Brain },
            { id: 'ai', label: 'AI Models', icon: Cpu },
            { id: 'formulas', label: 'Formulas', icon: Code },
            { id: 'logs', label: 'Logs', icon: Activity }
          ].map(item => {
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => setActiveModule(item.id)}
                className={`w-full flex items-center space-x-3 p-3 rounded transition ${
                  activeModule === item.id ? 'bg-blue-600' : 'hover:bg-gray-800'
                }`}
              >
                <Icon size={20} />
                {sidebarOpen && <span>{item.label}</span>}
              </button>
            );
          })}
        </nav>

        <div className="p-4 border-t border-gray-700 text-xs text-gray-400">
          {sidebarOpen && <p>© 2025 Master System</p>}
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-auto">
        <div className="p-8">
          {activeModule === 'home' && renderHome()}
          {activeModule === 'skills' && renderSkills()}
          {activeModule === 'analysis' && renderAnalysis()}
          {activeModule === 'ai' && renderAI()}
          {activeModule === 'formulas' && renderFormulas()}
          {activeModule === 'logs' && renderLogs()}
        </div>
      </div>
    </div>
  );
};

export default UnifiedMasterDashboard;