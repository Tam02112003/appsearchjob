<div class="dark:[&amp;_pre:has(code)]:bg-shade dark:[&amp;_code[data-lang]]:bg-shade relative flex flex-col gap-1 rounded-md border-[0.5px] border-[#d0d0d0] bg-[#f8f8f8] p-4 text-white [overflow-wrap:anywhere] dark:border-[#2F2F2F] dark:bg-[#141414] [&amp;_pre]:my-3"><div data-state="closed"><div class="flex flex-col gap-2"><button type="button" aria-controls="radix-«r11v»" aria-expanded="false" data-state="closed" class="flex w-fit items-center gap-1.5 text-sm text-neutral-300"><svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256" class="size-4 transition-transform"><path d="M181.66,133.66l-80,80a8,8,0,0,1-11.32-11.32L164.69,128,90.34,53.66a8,8,0,0,1,11.32-11.32l80,80A8,8,0,0,1,181.66,133.66Z"></path></svg><span class="">Thought Process</span></button><div data-state="closed" id="radix-«r11v»" style="--radix-collapsible-content-height: 160px; --radix-collapsible-content-width: 834px;" hidden=""></div></div></div><div class="prose-custom prose-custom-md prose-custom-gray !max-w-none text-neutral-300 [overflow-wrap:anywhere]"><h1 class="group flex items-center">Flutter Job Search App with AWS Backend  </h1>

<h2 class="group flex items-center">📱 Project Overview  </h2>
<p>A Flutter-based job search application that uses AWS Amplify for backend services. The app provides user authentication through Amazon Cognito and includes features like theme switching. <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">main.dart:36-66</span></p>
<h2 class="group flex items-center">✨ Features  </h2>
<ul>
<li><strong>User Authentication</strong>: Secure login system using AWS Cognito <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">main.dart:23-34</span></li>
<li><strong>Dark/Light Theme Support</strong>: User-customizable interface themes <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">main.dart:42-50</span></li>
<li><strong>Image Management</strong>: Support for image uploading and viewing <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:16</span></li>
<li><strong>Calendar Integration</strong>: Date selection functionality <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:30</span></li>
</ul>
<h2 class="group flex items-center">🛠️ Technologies Used  </h2>
<ul>
<li><strong>Flutter</strong>: Framework for building cross-platform applications <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:13-14</span></li>
<li><strong>AWS Amplify</strong>: Backend services and authentication <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:17-19</span></li>
<li><strong>Provider</strong>: State management solution <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:21</span></li>
<li><strong>Other key packages</strong>:
<ul>
<li><code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">image_picker</code> for handling image uploads</li>
<li><code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">http</code> for network requests</li>
<li><code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">shared_preferences</code> for local storage <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:16-32</span></li>
</ul>
</li>
</ul>
<h2 class="group flex items-center">🚀 Getting Started  </h2>
<h3 class="group flex items-center">Prerequisites  </h3>
<ul>
<li>Flutter SDK (^3.5.4) <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">pubspec.yaml:9</span></li>
<li>AWS Account</li>
<li>Amplify CLI</li>
</ul>
<h3 class="group flex items-center">Installation  </h3>
<ol>
<li>
<p><strong>Clone the repository</strong></p>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>git clone https:</span><span style="color: rgb(0, 153, 38);">//gi</span><span>thub.com</span><span style="color: rgb(0, 153, 38);">/your_username/</span><span>appsearchjob.git  
</span>cd appsearchjob</code></pre></pre>
</li>
<li>
<p><strong>Install dependencies</strong></p>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>flutter pub </span><span style="color: rgb(51, 51, 51); font-weight: bold;">get</span></code></pre></pre>
</li>
<li>
<p><strong>Configure AWS Amplify</strong></p>
<p>If you're starting from scratch:</p>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>amplify init  
</span><span>amplify </span><span style="color: rgb(51, 51, 51); font-weight: bold;">add</span><span> auth  
</span><span>amplify </span><span style="color: rgb(51, 51, 51); font-weight: bold;">push</span></code></pre></pre>
<p>If you're using the existing configuration:</p>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>amplify pull </span><span style="color: rgb(153, 153, 136); font-style: italic;">--appId YOUR_APP_ID</span></code></pre></pre>
</li>
<li>
<p><strong>Run the app</strong></p>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>flutter </span><span style="color: rgb(0, 134, 179);">run</span></code></pre></pre>
</li>
</ol>
<h2 class="group flex items-center">📁 Project Structure  </h2>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">lib/  
├── models/        # Data models  
├── screens/       # UI screens  
├── services/      # API and service integrations  
├── utils/         # Utility functions  
└── main.dart      # Application entry point  
</code></pre>
<p><span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">lib:1-5</span></p>
<h2 class="group flex items-center">🔐 AWS Configuration  </h2>
<p>The app uses AWS Amplify for backend services, particularly AWS Cognito for authentication. <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">main.dart:23-34</span></p>
<h3 class="group flex items-center">Authentication  </h3>
<p>The authentication is implemented using Amplify Auth with Cognito. User sessions are automatically checked when the app launches. <span role="link" tabindex="0" class="bg-pacific/10 text-pacific active:bg-pacific/20 hover:bg-pacific/20 cursor-pointer rounded-md px-[0.25rem] py-[0.12rem] text-xs font-normal leading-[15px] transition-colors duration-100 before:hidden after:hidden" style="font-family: &quot;IBM Plex Mono&quot;, &quot;IBM Plex Mono Fallback&quot;; font-weight: 400; font-style: normal;">main.dart:68-75</span></p>
<h2 class="group flex items-center">🖥️ Development  </h2>
<h3 class="group flex items-center">Adding Features  </h3>
<ol>
<li>Create new screens in the <code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">screens/</code> directory</li>
<li>Add models to the <code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">models/</code> directory</li>
<li>Implement services in the <code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">services/</code> directory</li>
<li>Update the README with new features</li>
</ol>
<h3 class="group flex items-center">Building for Production  </h3>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span style="color: rgb(221, 17, 68);">flutter</span><span> </span><span style="color: rgb(221, 17, 68);">build</span><span> </span><span style="color: rgb(221, 17, 68);">apk</span><span> </span><span style="color: rgb(0, 134, 179);">--release</span><span>  </span><span style="color: rgb(153, 153, 136); font-style: italic;"># For Android  </span><span>
</span><span></span><span style="color: rgb(221, 17, 68);">flutter</span><span> </span><span style="color: rgb(221, 17, 68);">build</span><span> </span><span style="color: rgb(221, 17, 68);">ios</span><span> </span><span style="color: rgb(0, 134, 179);">--release</span><span>  </span><span style="color: rgb(153, 153, 136); font-style: italic;"># For iOS</span></code></pre></pre>
<h2 class="group flex items-center">📊 Testing  </h2>
<pre class="px-2 py-1.5 has-[code]:rounded-md has-[code]:!bg-[#e5e5e5] has-[div]:bg-transparent has-[div]:!p-0 has-[code]:text-stone-900 dark:has-[code]:!bg-[#242424] has-[code]:dark:text-white [&amp;_code]:block [&amp;_code]:border-none [&amp;_code]:bg-transparent [&amp;_code]:p-0"><pre style="display: block; overflow-x: auto; padding: 6px 8px; color: rgb(51, 51, 51); background: transparent; margin: 0px; width: 100%;"><code style="white-space: pre; font-size: 12px;"><span>flutter </span><span style="color: rgb(0, 134, 179);">test</span></code></pre></pre>
<h2 class="group flex items-center">📄 License  </h2>
<p>This project is licensed under the MIT License - see the LICENSE file for details.</p>
<h2 class="group flex items-center">🤝 Contributing  </h2>
<ol>
<li>Fork the repository</li>
<li>Create your feature branch (<code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">git checkout -b feature/amazing-feature</code>)</li>
<li>Commit your changes (<code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">git commit -m 'Add some amazing feature'</code>)</li>
<li>Push to the branch (<code class="rounded-sm bg-[#e5e5e5] px-[0.25rem] py-[0.20rem] text-xs font-normal leading-[15px] before:hidden after:hidden dark:bg-[#484848]/30">git push origin feature/amazing-feature</code>)</li>
<li>Open a Pull Request</li>
</ol>
<h2 class="group flex items-center">Notes  </h2>
<ul>
<li>This README template is based on the specific structure and dependencies of your Flutter project with AWS Amplify integration.</li>
<li>Make sure to replace placeholder content (such as YOUR_APP_ID) with your actual project details.</li>
<li>Consider adding screenshots, more specific setup instructions, and troubleshooting information as your project develops.</li>
<li>The template includes sections for all major aspects of a modern mobile application project to ensure comprehensive documentation.</li>
</ul></div><div class="flex items-center gap-1 text-neutral-300"><button class="rounded-lg p-1.5 transition-colors hover:bg-white/10 hover:text-white"><svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256" class="h-4 w-4"><path d="M234,80.12A24,24,0,0,0,216,72H160V56a40,40,0,0,0-40-40,8,8,0,0,0-7.16,4.42L75.06,96H32a16,16,0,0,0-16,16v88a16,16,0,0,0,16,16H204a24,24,0,0,0,23.82-21l12-96A24,24,0,0,0,234,80.12ZM32,112H72v88H32ZM223.94,97l-12,96a8,8,0,0,1-7.94,7H88V105.89l36.71-73.43A24,24,0,0,1,144,56V80a8,8,0,0,0,8,8h64a8,8,0,0,1,7.94,9Z"></path></svg></button><button class="rounded-lg p-1.5 transition-colors hover:bg-white/10 hover:text-white"><svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" viewBox="0 0 256 256" class="h-4 w-4"><path d="M239.82,157l-12-96A24,24,0,0,0,204,40H32A16,16,0,0,0,16,56v88a16,16,0,0,0,16,16H75.06l37.78,75.58A8,8,0,0,0,120,240a40,40,0,0,0,40-40V184h56a24,24,0,0,0,23.82-27ZM72,144H32V56H72Zm150,21.29a7.88,7.88,0,0,1-6,2.71H152a8,8,0,0,0-8,8v24a24,24,0,0,1-19.29,23.54L88,150.11V56H204a8,8,0,0,1,7.94,7l12,96A7.87,7.87,0,0,1,222,165.29Z"></path></svg></button></div></div>
